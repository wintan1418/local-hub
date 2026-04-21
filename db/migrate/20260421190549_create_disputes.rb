class CreateDisputes < ActiveRecord::Migration[8.0]
  def change
    create_table :disputes do |t|
      t.references :booking, null: false, foreign_key: true
      t.integer :raised_by_id
      t.string :reason
      t.text :description
      t.integer :status
      t.text :resolution
      t.datetime :resolved_at
      t.decimal :refund_amount

      t.timestamps
    end
  end
end
