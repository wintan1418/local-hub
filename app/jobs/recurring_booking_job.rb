class RecurringBookingJob < ApplicationJob
  queue_as :default

  # Creates next occurrence of a recurring booking after completion
  def perform(booking_id)
    booking = Booking.find_by(id: booking_id)
    return unless booking && booking.recurring? && booking.completed?
    return if Booking.exists?(parent_booking_id: booking.id, scheduled_at: booking.next_occurrence_date)

    next_date = booking.next_occurrence_date
    return unless next_date

    Booking.create!(
      customer: booking.customer,
      service: booking.service,
      scheduled_at: next_date,
      total_price: booking.total_price,
      status: :pending,
      recurrence: booking.recurrence,
      parent_booking_id: booking.id
    )
    Rails.logger.info "Created next recurring booking for #{booking.id} on #{next_date}"
  end
end
