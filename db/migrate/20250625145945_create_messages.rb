class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.references :booking, null: false, foreign_key: true
      t.text :content
      t.boolean :read

      t.timestamps
    end
  end
end
