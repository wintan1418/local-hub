class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_customer!, only: [ :create, :payment_success ]

  def index
    if current_user.customer?
      @bookings = current_user.bookings.includes(service: [:provider, :category]).order(created_at: :desc)
    elsif current_user.provider?
      @bookings = Booking.joins(:service).where(services: { provider_id: current_user.id }).includes(service: [:category], customer: []).order(created_at: :desc)
    else
      redirect_to root_path and return
    end

    @bookings = @bookings.where(status: params[:status]) if params[:status].present?
    @bookings = @bookings.page(params[:page]).per(15)
  end

  def show
    @booking = Booking.includes(service: :provider).find(params[:id])
    # Allow customer or provider to view
    unless @booking.customer == current_user || @booking.service.provider == current_user || current_user.admin?
      redirect_to root_path, alert: "Access denied."
    end
  end

  def create
    @service = Service.find(params[:service_id])
    @booking = Booking.new(booking_params)
    @booking.customer = current_user
    @booking.service = @service
    @booking.status = :pending
    @booking.paid = false

    if @booking.save
      result = StripeService.create_booking_checkout(@booking)

      if result && result[:checkout_url]
        redirect_to result[:checkout_url], allow_other_host: true
      else
        redirect_to booking_path(@booking), notice: "Booking created! Payment will be collected later."
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

    redirect_to booking_path(@booking), notice: "Booking confirmed and payment received!"
  end

  def reschedule
    @booking = Booking.find(params[:id])
    unless @booking.customer == current_user || @booking.service.provider == current_user
      respond_to do |format|
        format.html { redirect_to root_path, alert: "Access denied." }
        format.json { render json: { error: "Access denied" }, status: :forbidden }
      end
      return
    end

    new_time = params[:scheduled_at]
    if new_time.present? && @booking.update(scheduled_at: new_time)
      Notification.create_for_booking(@booking, :updated, "Booking rescheduled to #{@booking.scheduled_at.strftime('%b %d at %-I:%M %p')}")
      respond_to do |format|
        format.html { redirect_to booking_path(@booking), notice: "Booking rescheduled." }
        format.json { render json: { ok: true, scheduled_at: @booking.scheduled_at } }
      end
    else
      message = @booking.errors.full_messages.to_sentence.presence || "New date/time required."
      respond_to do |format|
        format.html { redirect_to booking_path(@booking), alert: message }
        format.json { render json: { error: message }, status: :unprocessable_entity }
      end
    end
  end

  def add_tip
    @booking = current_user.bookings.find(params[:id])
    amount = params[:tip_amount].to_f
    if amount >= 0 && @booking.completed?
      @booking.update(tip_amount: amount)
      redirect_to booking_path(@booking), notice: "Thanks for the $#{amount} tip!"
    else
      redirect_to booking_path(@booking), alert: "Could not add tip."
    end
  end

  def destroy
    @booking = current_user.bookings.find(params[:id])
    @booking.cancelled!
    redirect_to customer_dashboard_path, notice: "Booking cancelled."
  end

  private

  def booking_params
    params.require(:booking).permit(:scheduled_at, :total_price, :recurrence, :urgent, :service_package_id, :notes_from_customer, photos: [])
  end

  def ensure_customer!
    redirect_to root_path, alert: "Access denied." unless current_user&.customer?
  end
end
