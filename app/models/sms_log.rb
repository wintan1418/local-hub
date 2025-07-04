class SmsLog < ApplicationRecord
  belongs_to :user

  enum :message_type, {
    verification: 0,
    booking_confirmation: 1,
    booking_reminder: 2,
    marketing: 3,
    service_update: 4,
    chat_notification: 5
  }, default: :service_update

  enum :status, {
    pending: 0,
    sent: 1,
    delivered: 2,
    failed: 3,
    undelivered: 4
  }, default: :pending

  validates :phone_number, presence: true
  validates :content, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :delivered, -> { where(status: :delivered) }
  scope :failed, -> { where(status: [ :failed, :undelivered ]) }

  def mark_sent!(twilio_sid)
    update(
      status: :sent,
      twilio_sid: twilio_sid,
      sent_at: Time.current
    )
  end

  def mark_delivered!
    update(
      status: :delivered,
      delivered_at: Time.current
    )
  end

  def mark_failed!(error_message)
    update(
      status: :failed,
      error_message: error_message
    )
  end
end
