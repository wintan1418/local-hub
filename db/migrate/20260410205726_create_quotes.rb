class CreateQuotes < ActiveRecord::Migration[8.0]
  def change
    create_table :quotes do |t|
      t.references :service, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: { to_table: :users }
      t.references :provider, null: false, foreign_key: { to_table: :users }
      t.string :title
      t.text :description
      t.decimal :total_price, precision: 10, scale: 2
      t.integer :status, default: 0
      t.datetime :valid_until
      t.text :notes

      t.timestamps
    end
  end
end
