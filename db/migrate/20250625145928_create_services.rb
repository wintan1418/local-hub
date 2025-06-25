class CreateServices < ActiveRecord::Migration[8.0]
  def change
    create_table :services do |t|
      t.references :provider, null: false, foreign_key: { to_table: :users }
      t.references :category, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.integer :price_type
      t.decimal :base_price

      t.timestamps
    end
  end
end
