class GiftCard < ApplicationRecord
  belongs_to :purchaser, class_name: "User", optional: true
  belongs_to :redeemed_by, class_name: "User", optional: true

  enum :status, { active: 0, redeemed: 1, expired: 2, cancelled: 3, pending: 4 }

  AMOUNTS = [ 25, 50, 100, 200, 500 ].freeze

  validates :amount, presence: true, numericality: { greater_than: 0 }, inclusion: { in: AMOUNTS, message: "must be one of: #{AMOUNTS.join(', ')}" }
  validates :code, uniqueness: true, allow_blank: true
  validates :recipient_email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }

  before_create :generate_code, :set_balance

  def formatted_code
    code.scan(/.{4}/).join("-")
  end

  def usable?
    active? && balance > 0
  end

  def apply_to_booking!(booking, amount_to_use)
    return false unless usable?
    amount_to_use = [amount_to_use, balance, booking.total_price].min
    update!(balance: balance - amount_to_use)
    update!(status: :redeemed) if balance <= 0
    booking.update!(gift_card_code: code, gift_card_amount_used: amount_to_use)
    amount_to_use
  end

  private

  def generate_code
    loop do
      self.code = SecureRandom.hex(8).upcase
      break unless GiftCard.exists?(code: self.code)
    end
  end

  def set_balance
    self.balance ||= amount
  end
end
