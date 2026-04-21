class CreateJobRequestQuotes < ActiveRecord::Migration[8.0]
  def change
    create_table :job_request_quotes do |t|
      t.references :job_request, null: false, foreign_key: true
      t.references :provider, null: false, foreign_key: { to_table: :users }
      t.decimal :price, precision: 10, scale: 2
      t.text :message
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
