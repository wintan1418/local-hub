class PhoneVerification < ApplicationRecord
  belongs_to :user

  validates :phone, presence: true, format: { with: /\A\+?[1-9]\d{1,14}\z/ }
  validates :code, presence: true, length: { is: 6 }
  validates :attempts, numericality: { greater_than_or_equal_to: 0 }

  scope :pending, -> { where(verified: false).where("expires_at > ?", Time.current) }
  scope :expired, -> { where(verified: false).where("expires_at <= ?", Time.current) }

  before_create :set_defaults

  def self.generate_for(user, phone)
    # Clean up old verifications
    user.phone_verifications.pending.update_all(verified: false, expires_at: Time.current)

    code = generate_code
    create(
      user: user,
      phone: phone,
      code: code,
      expires_at: 10.minutes.from_now,
      attempts: 0
    )
  end

  def verify!(input_code)
    return false if expired?
    return false if attempts >= 3

    increment!(:attempts)

    if input_code == code
      update(
        verified: true,
        verified_at: Time.current
      )
      user.update(phone: phone)
      true
    else
      false
    end
  end

  def expired?
    !verified? && expires_at < Time.current
  end

  def can_retry?
    !verified? && attempts < 3 && !expired?
  end

  private

  def self.generate_code
    SecureRandom.random_number(999999).to_s.rjust(6, "0")
  end

  def set_defaults
    self.verified ||= false
    self.attempts ||= 0
  end
end
