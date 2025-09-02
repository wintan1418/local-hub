class AddMessageFeaturesToChatMessages < ActiveRecord::Migration[8.0]
  def change
    add_reference :chat_messages, :reply_to, null: true, foreign_key: { to_table: :chat_messages }
    add_column :chat_messages, :pinned, :boolean, default: false
    add_column :chat_messages, :deleted_at, :timestamp, null: true
    add_column :chat_messages, :edited_at, :timestamp, null: true
    
    add_index :chat_messages, :pinned
    add_index :chat_messages, :deleted_at
  end
end
