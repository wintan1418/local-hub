class CreateInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :invoices do |t|
      t.references :booking, null: false, foreign_key: true
      t.string :invoice_number
      t.decimal :amount, precision: 10, scale: 2
      t.integer :status, default: 0
      t.datetime :issued_at
      t.datetime :paid_at

      t.timestamps
    end
  end
end
