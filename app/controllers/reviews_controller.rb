class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking
  before_action :ensure_can_review!

  def new
    @review = @booking.build_review
  end

  def create
    @review = @booking.build_review(review_params)

    if @review.save
      redirect_to service_path(@booking.service), notice: "Thanks for your review!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_booking
    @booking = current_user.bookings.find(params[:booking_id])
  end

  def review_params
    params.require(:review).permit(:rating, :comment)
  end

  def ensure_can_review!
    unless @booking.completed? && @booking.review.nil?
      redirect_to customer_dashboard_path, alert: "You can only review completed bookings that haven't been reviewed yet."
    end
  end
end
