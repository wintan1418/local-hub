class CreateNotificationPreferences < ActiveRecord::Migration[8.0]
  def change
    create_table :notification_preferences do |t|
      t.references :user, null: false, foreign_key: true
      t.boolean :sms_enabled
      t.boolean :whatsapp_enabled
      t.boolean :email_enabled
      t.boolean :booking_reminders
      t.boolean :marketing_messages
      t.boolean :service_updates
      t.time :quiet_hours_start
      t.time :quiet_hours_end

      t.timestamps
    end
  end
end
