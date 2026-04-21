class CreateGiftCards < ActiveRecord::Migration[8.0]
  def change
    create_table :gift_cards do |t|
      t.string :code
      t.decimal :amount, precision: 10, scale: 2
      t.decimal :balance, precision: 10, scale: 2
      t.integer :purchaser_id
      t.integer :redeemed_by_id
      t.integer :status, default: 0
      t.text :message
      t.string :recipient_email
      t.string :recipient_name

      t.timestamps
    end
    add_index :gift_cards, :code, unique: true
  end
end
