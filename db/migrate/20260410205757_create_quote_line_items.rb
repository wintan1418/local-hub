class CreateQuoteLineItems < ActiveRecord::Migration[8.0]
  def change
    create_table :quote_line_items do |t|
      t.references :quote, null: false, foreign_key: true
      t.string :description
      t.integer :quantity
      t.decimal :unit_price

      t.timestamps
    end
  end
end
