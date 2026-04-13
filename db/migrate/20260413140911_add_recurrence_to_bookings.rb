class AddRecurrenceToBookings < ActiveRecord::Migration[8.0]
  def change
    add_column :bookings, :recurrence, :integer
    add_column :bookings, :parent_booking_id, :integer
  end
end
