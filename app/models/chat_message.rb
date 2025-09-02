class ChatMessage < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, class_name: "User"
  belongs_to :reply_to, class_name: "ChatMessage", optional: true
  
  # Support for file attachments
  has_many_attached :attachments
  
  # Message relationships
  has_many :replies, class_name: "ChatMessage", foreign_key: "reply_to_id", dependent: :destroy

  enum :message_type, { text: 0, image: 1, file: 2, voice: 3, system: 4 }, default: :text

  validates :content, presence: true, unless: :has_attachments_or_reply?

  # Validate attachments
  validate :attachments_validations, if: -> { attachments.attached? }
  
  # Message states
  scope :pinned, -> { where(pinned: true) }
  scope :not_deleted, -> { where(deleted_at: nil) }
  scope :visible, -> { not_deleted }
  scope :unread_for, ->(user) { where(read_at: nil).where.not(sender: user) }
  scope :recent, -> { order(:created_at) }

  after_create :update_conversation
  after_create :increment_unread_count

  def read_by?(user)
    read_at.present? && sender != user
  end

  def mark_as_read!
    update(read_at: Time.current) if read_at.nil?
  end

  def has_attachments?
    attachments.attached?
  end
  
  def has_attachments_or_reply?
    has_attachments? || reply_to.present?
  end
  
  # Check if message is edited
  def edited?
    updated_at > created_at + 1.minute
  end
  
  # Soft delete
  def soft_delete!
    update(deleted_at: Time.current, content: "[Message deleted]")
  end
  
  def deleted?
    deleted_at.present?
  end
  
  # Pin/unpin message
  def toggle_pin!
    update(pinned: !pinned?)
  end
  
  def pinned?
    pinned == true
  end
  
  # Extract mentions from content
  def mentions
    return [] unless content.present?
    content.scan(/@(\w+)/).flatten
  end
  
  # Check if message can be edited/deleted by user
  def can_modify?(user)
    sender == user && !deleted? && created_at > 15.minutes.ago
  end

  private

  def update_conversation
    conversation.update(last_message_at: created_at)
  end

  def increment_unread_count
    conversation.increment_unread_for(sender)
  end

  def attachments_validations
    attachments.each do |attachment|
      # File size validation (max 10MB)
      if attachment.blob.byte_size > 10.megabytes
        errors.add(:attachments, "File size should be less than 10MB")
      end

      # File type validation
      allowed_types = %w[
        image/jpeg image/png image/gif image/webp
        application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document
        audio/mpeg audio/wav audio/mp4 audio/webm
        video/mp4 video/webm
        text/plain
      ]
      
      unless allowed_types.include?(attachment.blob.content_type)
        errors.add(:attachments, "File type not supported")
      end
    end
  end

  def attachment_type(attachment)
    content_type = attachment.blob.content_type
    case content_type
    when /^image\//
      :image
    when /^audio\//
      :audio
    when /^video\//
      :video
    when 'application/pdf'
      :pdf
    when /word|document/
      :document
    else
      :file
    end
  end
end
