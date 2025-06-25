class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :bookings do |t|
      t.references :customer, null: false, foreign_key: { to_table: :users }
      t.references :service, null: false, foreign_key: true
      t.datetime :scheduled_at
      t.integer :status
      t.decimal :total_price

      t.timestamps
    end
  end
end
