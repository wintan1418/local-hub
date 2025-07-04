class CreateSmsLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :sms_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :phone_number
      t.string :message_type
      t.text :content
      t.string :status
      t.string :twilio_sid
      t.string :error_message
      t.datetime :sent_at
      t.datetime :delivered_at

      t.timestamps
    end
  end
end
