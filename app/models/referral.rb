class Referral < ApplicationRecord
  belongs_to :referrer, class_name: "User"
  belongs_to :referee, class_name: "User", optional: true

  enum :status, { pending: 0, completed: 1, rewarded: 2 }

  CREDIT_AMOUNT = 10.00

  before_create :generate_code

  private

  def generate_code
    self.code ||= "REF-#{SecureRandom.hex(4).upcase}"
  end
end
