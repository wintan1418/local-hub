class CreatePlans < ActiveRecord::Migration[8.0]
  def change
    create_table :plans do |t|
      t.string :name, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.string :stripe_price_id
      t.text :features
      t.boolean :active, default: true
      t.integer :billing_period, default: 0
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :plans, :stripe_price_id, unique: true
    add_index :plans, :active
  end
end
