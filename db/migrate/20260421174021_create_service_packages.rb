class CreateServicePackages < ActiveRecord::Migration[8.0]
  def change
    create_table :service_packages do |t|
      t.references :service, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.decimal :price
      t.integer :sort_order

      t.timestamps
    end
  end
end
