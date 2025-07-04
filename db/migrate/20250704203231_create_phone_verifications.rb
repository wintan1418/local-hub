class CreatePhoneVerifications < ActiveRecord::Migration[8.0]
  def change
    create_table :phone_verifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :phone
      t.string :code
      t.boolean :verified
      t.datetime :verified_at
      t.datetime :expires_at
      t.integer :attempts

      t.timestamps
    end
  end
end
