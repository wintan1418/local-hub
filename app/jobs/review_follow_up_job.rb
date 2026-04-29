class ReviewFollowUpJob < ApplicationJob
  queue_as :default

  # Safety-net batch: catches bookings whose per-booking
  # BookingReviewReminderJob didn't fire (worker downtime, code shipped after
  # the booking was completed, etc.). Filter on scheduled_at so we don't
  # re-send when other fields like tip_amount get touched after completion.
  def perform
    completed = Booking.where(status: :completed)
                       .where(scheduled_at: 5.days.ago..1.day.ago)
                       .left_joins(:review)
                       .where(reviews: { id: nil })
                       .includes(:customer, service: :provider)

    sent = 0
    completed.find_each do |booking|
      next if booking.customer&.email.blank?
      BookingMailer.review_reminder(booking).deliver_later
      sent += 1
    end

    Rails.logger.info "ReviewFollowUpJob: queued #{sent} review reminders"
  end
end
