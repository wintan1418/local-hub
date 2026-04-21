class AddFieldsToUsersAndBookings < ActiveRecord::Migration[8.0]
  def change
    # Users
    add_column :users, :vacation_until, :datetime
    add_column :users, :referral_code, :string
    add_column :users, :referral_credit, :decimal, precision: 10, scale: 2, default: 0
    add_index :users, :referral_code, unique: true

    # Bookings
    add_column :bookings, :urgent, :boolean, default: false
    add_column :bookings, :first_response_at, :datetime
    add_column :bookings, :service_package_id, :integer
    add_reference :bookings, :referral, foreign_key: false, null: true
    add_column :bookings, :notes_from_customer, :text
  end
end
