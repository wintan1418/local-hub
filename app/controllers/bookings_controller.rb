class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_customer!

  def create
    @service = Service.find(params[:service_id])
    @booking = Booking.new(booking_params)
    @booking.customer = current_user
    @booking.service = @service
    @booking.status = :pending
    if @booking.save
      respond_to do |format|
        format.html { redirect_to customer_dashboard_path, notice: 'Booking created successfully!' }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { redirect_to service_path(@service), alert: @booking.errors.full_messages.to_sentence }
        format.turbo_stream
      end
    end
  end

  def destroy
    @booking = current_user.bookings.find(params[:id])
    @booking.destroy
    respond_to do |format|
      format.html { redirect_to customer_dashboard_path, notice: 'Booking cancelled.' }
      format.turbo_stream
    end
  end

  private

  def booking_params
    params.require(:booking).permit(:scheduled_at, :total_price)
  end

  def ensure_customer!
    redirect_to root_path, alert: 'Access denied.' unless current_user&.user_role == 'customer'
  end
end 