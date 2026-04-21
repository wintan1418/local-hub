class CreateFavorites < ActiveRecord::Migration[8.0]
  def change
    create_table :favorites do |t|
      t.references :customer, null: false, foreign_key: { to_table: :users }
      t.references :provider, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end
    add_index :favorites, [:customer_id, :provider_id], unique: true
  end
end
