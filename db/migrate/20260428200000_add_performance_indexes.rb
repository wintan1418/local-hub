class AddPerformanceIndexes < ActiveRecord::Migration[8.0]
  def change
    add_index :bookings, [ :status, :scheduled_at ], if_not_exists: true
    add_index :bookings, :scheduled_at, if_not_exists: true
    add_index :bookings, :created_at, if_not_exists: true

    add_index :disputes, :status, if_not_exists: true

    add_index :job_requests, [ :status, :created_at ], if_not_exists: true

    add_index :gift_cards, :status, if_not_exists: true

    add_index :referrals, :code, unique: true, if_not_exists: true
    add_index :referrals, :referrer_id, if_not_exists: true
    add_index :referrals, :referee_id, if_not_exists: true
    add_index :referrals, :status, if_not_exists: true

    add_index :messages, :created_at, if_not_exists: true
    add_index :reviews, :created_at, if_not_exists: true
    add_index :services, :created_at, if_not_exists: true
  end
end
