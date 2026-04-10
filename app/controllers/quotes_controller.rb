class QuotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_quote

  def show
    # Both customer and provider can view
  end

  def approve
    if @quote.sent? && @quote.customer == current_user
      @quote.approved!
      booking = @quote.convert_to_booking!
      redirect_to customer_dashboard_path, notice: "Quote approved! Booking ##{booking.id} created."
    else
      redirect_to quote_path(@quote), alert: "Cannot approve this quote."
    end
  end

  def reject
    if @quote.sent? && @quote.customer == current_user
      @quote.rejected!
      redirect_to customer_dashboard_path, notice: "Quote declined."
    else
      redirect_to quote_path(@quote), alert: "Cannot reject this quote."
    end
  end

  private

  def set_quote
    @quote = Quote.find(params[:id])
    unless @quote.customer == current_user || @quote.provider == current_user
      redirect_to root_path, alert: "Access denied."
    end
  end
end
