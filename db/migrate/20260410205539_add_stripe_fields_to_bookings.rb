class AddStripeFieldsToBookings < ActiveRecord::Migration[8.0]
  def change
    add_column :bookings, :stripe_payment_intent_id, :string
    add_column :bookings, :stripe_checkout_session_id, :string
    add_column :bookings, :paid, :boolean
  end
end
