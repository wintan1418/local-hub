class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_customer!, only: [ :create, :payment_success ]

  def index
    if current_user.customer?
      @bookings = current_user.bookings.includes(service: [ :provider, :category ])
    elsif current_user.provider?
      @bookings = Booking.joins(:service).where(services: { provider_id: current_user.id }).includes(:customer, service: [ :provider, :category ])
    else
      redirect_to root_path and return
    end

    @bookings = @bookings.where(status: params[:status]) if params[:status].present?

    if params[:q].present?
      @bookings = @bookings.joins(:service).where("services.title ILIKE ?", "%#{params[:q]}%")
    end

    @bookings = case params[:sort]
    when "oldest"     then @bookings.order(created_at: :asc)
    when "upcoming"   then @bookings.order(scheduled_at: :asc)
    when "price_high" then @bookings.order(total_price: :desc)
    when "price_low"  then @bookings.order(total_price: :asc)
    else                   @bookings.order(created_at: :desc)
    end

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
    @booking = Booking.new(booking_params.except(:service_package_id))
    @booking.customer = current_user
    @booking.service = @service
    @booking.status = :pending
    @booking.paid = false

    package = selected_package
    return if performed?

    @booking.service_package = package
    @booking.total_price = calculated_booking_price(package)

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
    payment_verified = @booking.paid?

    if session_id.present?
      begin
        session = Stripe::Checkout::Session.retrieve(session_id)
        if StripeService.checkout_session_paid_for_booking?(session, @booking)
          @booking.update(
            paid: true,
            stripe_payment_intent_id: session.payment_intent,
            stripe_checkout_session_id: session_id
          )
          payment_verified = true
        else
          Rails.logger.warn "Stripe checkout session verification failed for booking #{@booking.id}"
        end
      rescue Stripe::StripeError => e
        Rails.logger.error "Stripe session retrieve error: #{e.message}"
      end
    end

    if payment_verified
      redirect_to booking_path(@booking), notice: "Booking confirmed and payment received!"
    else
      redirect_to booking_path(@booking), alert: "Payment could not be verified yet."
    end
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

    new_time = parse_scheduled_at(params[:scheduled_at])

    error = reschedule_validation_error(@booking, new_time)
    if error
      respond_to do |format|
        format.html { redirect_to booking_path(@booking), alert: error }
        format.json { render json: { error: error }, status: :unprocessable_entity }
      end
      return
    end

    if @booking.update(scheduled_at: new_time)
      Notification.create_for_booking(@booking, :updated, "Booking rescheduled to #{@booking.scheduled_at.strftime('%b %d at %-I:%M %p')}")
      respond_to do |format|
        format.html { redirect_to booking_path(@booking), notice: "Booking rescheduled." }
        format.json { render json: { ok: true, scheduled_at: @booking.scheduled_at } }
      end
    else
      message = @booking.errors.full_messages.to_sentence.presence || "Could not reschedule."
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
    params.require(:booking).permit(:scheduled_at, :recurrence, :urgent, :service_package_id, :notes_from_customer, photos: [])
  end

  def ensure_customer!
    redirect_to root_path, alert: "Access denied." unless current_user&.customer?
  end

  def selected_package
    package_id = booking_params[:service_package_id]
    return nil if package_id.blank?

    package = @service.packages.find_by(id: package_id)
    return package if package

    redirect_to service_path(@service), alert: "Selected package is not available for this service."
    nil
  end

  def calculated_booking_price(package)
    package&.price || @service.base_price
  end

  def parse_scheduled_at(raw)
    return nil if raw.blank?
    raw.is_a?(Time) ? raw : Time.zone.parse(raw.to_s)
  rescue ArgumentError
    nil
  end

  def reschedule_validation_error(booking, new_time)
    return "New date/time required." if new_time.nil?
    return "Booking must be at least 1 hour from now." if new_time < 1.hour.from_now
    return "Provider is not available at that time." unless booking.service.available_on?(new_time)
    return "That time slot conflicts with another booking." if reschedule_conflict?(booking, new_time)
    nil
  end

  def reschedule_conflict?(booking, new_time)
    Booking.joins(:service)
           .where(services: { provider_id: booking.service.provider_id })
           .where.not(id: booking.id)
           .where.not(status: :cancelled)
           .where(scheduled_at: (new_time - 1.hour)..(new_time + 1.hour))
           .exists?
  end
end
