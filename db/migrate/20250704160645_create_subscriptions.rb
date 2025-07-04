class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :status
      t.integer :plan_type
      t.string :stripe_subscription_id
      t.string :stripe_customer_id
      t.datetime :current_period_start
      t.datetime :current_period_end
      t.boolean :cancel_at_period_end, default: false
      t.references :plan, foreign_key: true

      t.timestamps
    end
    
    add_index :subscriptions, :stripe_subscription_id, unique: true
    add_index :subscriptions, :stripe_customer_id
  end
end
