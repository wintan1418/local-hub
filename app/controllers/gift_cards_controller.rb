class GiftCardsController < ApplicationController
  before_action :authenticate_user!, except: [:redeem]

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
    @gift_card.status = :active

    if @gift_card.save
      # TODO: trigger Stripe charge for purchase amount
      redirect_to gift_card_path(@gift_card), notice: "Gift card created! Share the code: #{@gift_card.formatted_code}"
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
