class CreateChatMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :chat_messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.text :content
      t.datetime :read_at
      t.integer :message_type, default: 0

      t.timestamps
    end

    add_index :chat_messages, :created_at
    add_index :chat_messages, [ :conversation_id, :created_at ]
  end
end
