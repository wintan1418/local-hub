class InvoicesController < ApplicationController
  before_action :authenticate_user!

  def show
    @booking = Booking.find(params[:booking_id])
    @invoice = @booking.invoice

    unless @invoice
      redirect_to customer_dashboard_path, alert: "No invoice found for this booking."
      return
    end

    # Allow customer or provider to view
    unless @booking.customer == current_user || @booking.service.provider == current_user || current_user.admin?
      redirect_to root_path, alert: "Access denied."
    end
  end
end
