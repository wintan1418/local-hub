class GiftCardsController < ApplicationController
  before_action :authenticate_user!, except: [ :redeem ]

  def index
    @my_cards = current_user.gift_cards_purchased.order(created_at: :desc)
    @available_amounts = GiftCard::AMOUNTS
  end

  def new
    @gift_card = GiftCard.new
  end

  def create
    @gift_card = GiftCard.new(gift_card_params)
    @gift_card.purchaser = current_user
    @gift_card.balance = @gift_card.amount
    @gift_card.status = :pending

    if @gift_card.save
      result = StripeService.create_gift_card_checkout(@gift_card, current_user)
      if result && result[:checkout_url]
        redirect_to result[:checkout_url], allow_other_host: true
      else
        @gift_card.destroy
        redirect_to new_gift_card_path, alert: "Could not start checkout. Please try again."
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @gift_card = GiftCard.find(params[:id])
    unless @gift_card.purchaser == current_user || @gift_card.redeemed_by == current_user
      redirect_to gift_cards_path, alert: "Access denied."
    end
  end

  def payment_success
    @gift_card = current_user.gift_cards_purchased.find(params[:id])
    session_id = params[:session_id]

    if session_id.present? && @gift_card.pending?
      begin
        session = Stripe::Checkout::Session.retrieve(session_id)
        if StripeService.checkout_session_paid_for_gift_card?(session, @gift_card, current_user)
          @gift_card.update(status: :active)
          GiftCardMailer.recipient_notification(@gift_card).deliver_later if @gift_card.recipient_email.present?
        else
          Rails.logger.warn "Stripe gift card checkout session verification failed for gift card #{@gift_card.id}"
        end
      rescue Stripe::StripeError => e
        Rails.logger.error "Stripe gift card session error: #{e.message}"
      end
    end

    if @gift_card.active?
      redirect_to gift_card_path(@gift_card), notice: "Payment received! Share the code: #{@gift_card.formatted_code}"
    else
      redirect_to gift_card_path(@gift_card), alert: "Payment could not be verified yet."
    end
  end

  def redeem
    code = params[:code].to_s.gsub(/[^a-zA-Z0-9]/, "").upcase
    card = GiftCard.find_by(code: code)

    if card.nil?
      render json: { error: "Invalid code" }, status: :not_found
    elsif !card.usable?
      render json: { error: "This gift card has already been used or expired" }, status: :unprocessable_entity
    else
      render json: { valid: true, balance: card.balance, code: card.code }
    end
  end

  private

  def gift_card_params
    params.require(:gift_card).permit(:amount, :message, :recipient_name, :recipient_email)
  end
end
