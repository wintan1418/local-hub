class CreateJobRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :job_requests do |t|
      t.references :customer, null: false, foreign_key: { to_table: :users }
      t.references :category, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.decimal :budget_min, precision: 10, scale: 2
      t.decimal :budget_max, precision: 10, scale: 2
      t.datetime :needed_by
      t.string :city
      t.string :state
      t.string :zip
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
