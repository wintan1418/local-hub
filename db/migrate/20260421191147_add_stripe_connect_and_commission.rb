class AddStripeConnectAndCommission < ActiveRecord::Migration[8.0]
  def change
    # Users (providers) — Stripe Connect account
    add_column :users, :stripe_connect_id, :string
    add_column :users, :stripe_connect_onboarded, :boolean, default: false
    add_column :users, :stripe_connect_charges_enabled, :boolean, default: false
    add_column :users, :stripe_connect_payouts_enabled, :boolean, default: false

    # Bookings — platform commission tracking
    add_column :bookings, :platform_fee_cents, :integer, default: 0
    add_column :bookings, :provider_payout_cents, :integer, default: 0
    add_column :bookings, :stripe_transfer_id, :string
  end
end
