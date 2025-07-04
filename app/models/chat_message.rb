class ChatMessage < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, class_name: 'User'
  
  enum :message_type, { text: 0, image: 1, file: 2, system: 3 }, default: :text
  
  validates :content, presence: true
  
  after_create :update_conversation
  after_create :increment_unread_count
  
  scope :unread_for, ->(user) { where(read_at: nil).where.not(sender: user) }
  scope :recent, -> { order(:created_at) }
  
  def read_by?(user)
    read_at.present? && sender != user
  end
  
  def mark_as_read!
    update(read_at: Time.current) if read_at.nil?
  end
  
  private
  
  def update_conversation
    conversation.update(last_message_at: created_at)
  end
  
  def increment_unread_count
    conversation.increment_unread_for(sender)
  end
end
