class NotificationPreference < ApplicationRecord
  belongs_to :user

  validates :user_id, uniqueness: true

  after_initialize :set_defaults

  def self.for_user(user)
    find_or_create_by(user: user)
  end

  def can_send_sms?
    sms_enabled? && !in_quiet_hours?
  end

  def can_send_whatsapp?
    whatsapp_enabled? && !in_quiet_hours?
  end

  def can_send_email?
    email_enabled?
  end

  def in_quiet_hours?
    return false unless quiet_hours_start && quiet_hours_end

    current_time = Time.current.strftime("%H:%M")
    start_time = quiet_hours_start.strftime("%H:%M")
    end_time = quiet_hours_end.strftime("%H:%M")

    if start_time < end_time
      current_time >= start_time && current_time < end_time
    else # Quiet hours span midnight
      current_time >= start_time || current_time < end_time
    end
  end

  private

  def set_defaults
    self.sms_enabled ||= true
    self.whatsapp_enabled ||= false
    self.email_enabled ||= true
    self.booking_reminders ||= true
    self.marketing_messages ||= true
    self.service_updates ||= true
  end
end
