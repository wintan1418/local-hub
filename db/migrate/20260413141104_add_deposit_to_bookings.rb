class AddDepositToBookings < ActiveRecord::Migration[8.0]
  def change
    add_column :bookings, :deposit_amount, :decimal
    add_column :bookings, :deposit_paid, :boolean
  end
end
