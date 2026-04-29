class RepairStripeConnectAndCommissionColumns < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :stripe_connect_id, :string unless column_exists?(:users, :stripe_connect_id)
    add_column :users, :stripe_connect_onboarded, :boolean, default: false unless column_exists?(:users, :stripe_connect_onboarded)
    add_column :users, :stripe_connect_charges_enabled, :boolean, default: false unless column_exists?(:users, :stripe_connect_charges_enabled)
    add_column :users, :stripe_connect_payouts_enabled, :boolean, default: false unless column_exists?(:users, :stripe_connect_payouts_enabled)

    add_column :bookings, :platform_fee_cents, :integer, default: 0 unless column_exists?(:bookings, :platform_fee_cents)
    add_column :bookings, :provider_payout_cents, :integer, default: 0 unless column_exists?(:bookings, :provider_payout_cents)
    add_column :bookings, :stripe_transfer_id, :string unless column_exists?(:bookings, :stripe_transfer_id)
  end
end
