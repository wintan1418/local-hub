class Referral < ApplicationRecord
  belongs_to :referrer, class_name: "User"
  belongs_to :referee, class_name: "User", optional: true

  enum :status, { pending: 0, completed: 1, rewarded: 2 }

  CREDIT_AMOUNT = 10.00

  before_validation :generate_code, on: :create

  validates :code, presence: true, uniqueness: true
  validates :referrer_id, presence: true

  scope :recent, -> { order(created_at: :desc) }

  private

  def generate_code
    return if code.present?
    loop do
      self.code = "REF-#{SecureRandom.hex(4).upcase}"
      break unless Referral.exists?(code: code)
    end
  end
end
