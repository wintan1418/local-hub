class AddTipToBookings < ActiveRecord::Migration[8.0]
  def change
    add_column :bookings, :tip_amount, :decimal, precision: 10, scale: 2, default: 0
    add_column :bookings, :gift_card_code, :string
    add_column :bookings, :gift_card_amount_used, :decimal, precision: 10, scale: 2, default: 0
    add_column :bookings, :assigned_team_member_id, :integer
  end
end
