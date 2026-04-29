class BookingReviewReminderJob < ApplicationJob
  queue_as :mailers

  # Sent once per booking, 24h after completion. Idempotent — bails if the
  # booking is no longer completed or already has a review.
  def perform(booking_id)
    booking = Booking.find_by(id: booking_id)
    return unless booking
    return unless booking.completed?
    return if booking.review.present?
    return if booking.customer&.email.blank?

    BookingMailer.review_reminder(booking).deliver_later
  rescue ActiveRecord::RecordNotFound
    # Booking was deleted; silently drop.
  end
end
