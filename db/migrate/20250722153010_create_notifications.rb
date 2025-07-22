class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :notifiable, polymorphic: true, null: true
      t.string :notification_type, null: false
      t.string :title, null: false
      t.text :message, null: false
      t.datetime :read_at
      t.json :metadata

      t.timestamps
    end

    add_index :notifications, [:user_id, :created_at]
    add_index :notifications, [:user_id, :read_at]
    add_index :notifications, :notification_type
  end
end
