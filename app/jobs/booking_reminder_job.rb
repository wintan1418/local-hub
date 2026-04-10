class BookingReminderJob < ApplicationJob
  queue_as :default

  def perform
    # Send reminders for bookings scheduled in the next 24 hours
    upcoming = Booking.where(status: [:pending, :confirmed])
                      .where(scheduled_at: 23.hours.from_now..25.hours.from_now)
                      .includes(:customer, service: :provider)

    upcoming.each do |booking|
      UserMailer.booking_reminder(booking).deliver_later
    end

    Rails.logger.info "BookingReminderJob: Sent #{upcoming.count} reminders"
  end
end
