class CreateConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :conversations do |t|
      t.references :customer, null: false, foreign_key: { to_table: :users }
      t.references :provider, null: false, foreign_key: { to_table: :users }
      t.integer :status, default: 0
      t.datetime :last_message_at
      t.integer :unread_count_customer, default: 0
      t.integer :unread_count_provider, default: 0

      t.timestamps
    end

    add_index :conversations, [ :customer_id, :provider_id ], unique: true
    add_index :conversations, :last_message_at
  end
end
