class CreateReferrals < ActiveRecord::Migration[8.0]
  def change
    create_table :referrals do |t|
      t.string :code
      t.integer :referrer_id
      t.integer :referee_id
      t.integer :status
      t.decimal :credit_amount

      t.timestamps
    end
  end
end
