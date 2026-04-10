class ReviewFollowUpJob < ApplicationJob
  queue_as :default

  def perform
    # Send review requests for bookings completed 24-48 hours ago without a review
    completed = Booking.where(status: :completed)
                       .where(updated_at: 48.hours.ago..24.hours.ago)
                       .left_joins(:review)
                       .where(reviews: { id: nil })
                       .includes(:customer, service: :provider)

    completed.each do |booking|
      UserMailer.review_request(booking).deliver_later
    end

    Rails.logger.info "ReviewFollowUpJob: Sent #{completed.count} review requests"
  end
end
