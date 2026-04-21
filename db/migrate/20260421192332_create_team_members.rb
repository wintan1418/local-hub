class CreateTeamMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :team_members do |t|
      t.references :provider, null: false, foreign_key: { to_table: :users }
      t.integer :member_id
      t.string :role
      t.integer :status, default: 0
      t.string :invite_email
      t.string :invite_token

      t.timestamps
    end
  end
end
