class CreateProviderFaqs < ActiveRecord::Migration[8.0]
  def change
    create_table :provider_faqs do |t|
      t.references :provider, null: false, foreign_key: { to_table: :users }
      t.string :question
      t.text :answer
      t.integer :sort_order

      t.timestamps
    end
  end
end
