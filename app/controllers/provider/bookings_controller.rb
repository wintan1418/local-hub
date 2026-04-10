class Provider::BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_provider!
  before_action :set_booking

  def confirm
    if @booking.pending?
      @booking.confirmed!
      redirect_to provider_dashboard_path, notice: "Booking confirmed!"
    else
      redirect_to provider_dashboard_path, alert: "Booking cannot be confirmed."
    end
  end

  def complete
    if @booking.confirmed?
      @booking.completed!
      redirect_to provider_dashboard_path, notice: "Booking marked as completed!"
    else
      redirect_to provider_dashboard_path, alert: "Only confirmed bookings can be completed."
    end
  end

  def cancel
    if @booking.pending? || @booking.confirmed?
      @booking.cancelled!
      redirect_to provider_dashboard_path, notice: "Booking cancelled."
    else
      redirect_to provider_dashboard_path, alert: "Booking cannot be cancelled."
    end
  end

  private

  def set_booking
    @booking = Booking.joins(:service).where(services: { provider_id: current_user.id }).find(params[:id])
  end

  def ensure_provider!
    redirect_to root_path, alert: "Access denied." unless current_user&.provider?
  end
end
