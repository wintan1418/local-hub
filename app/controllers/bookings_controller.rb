class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_customer!

  def create
    @service = Service.find(params[:service_id])
    @booking = Booking.new(booking_params)
    @booking.customer = current_user
    @booking.service = @service
    @booking.status = :pending
    @booking.paid = false

    if @booking.save
      # Create Stripe checkout session
      result = StripeService.create_booking_checkout(@booking)

      if result && result[:checkout_url]
        redirect_to result[:checkout_url], allow_other_host: true
      else
        # Stripe not configured or error — proceed without payment
        redirect_to customer_dashboard_path, notice: "Booking created! Payment will be collected later."
      end
    else
      redirect_to service_path(@service), alert: @booking.errors.full_messages.to_sentence
    end
  end

  def payment_success
    @booking = current_user.bookings.find(params[:id])
    session_id = params[:session_id]

    if session_id.present?
      begin
        session = Stripe::Checkout::Session.retrieve(session_id)
        if session.payment_status == "paid"
          @booking.update(
            paid: true,
            stripe_payment_intent_id: session.payment_intent,
            stripe_checkout_session_id: session_id
          )
        end
      rescue Stripe::StripeError => e
        Rails.logger.error "Stripe session retrieve error: #{e.message}"
      end
    end

    redirect_to customer_dashboard_path, notice: "Booking confirmed and payment received! Your provider will be in touch."
  end

  def destroy
    @booking = current_user.bookings.find(params[:id])
    @booking.cancelled!
    redirect_to customer_dashboard_path, notice: "Booking cancelled."
  end

  private

  def booking_params
    params.require(:booking).permit(:scheduled_at, :total_price)
  end

  def ensure_customer!
    redirect_to root_path, alert: "Access denied." unless current_user&.customer?
  end
end
