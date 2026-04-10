class Invoice < ApplicationRecord
  belongs_to :booking
  has_one :service, through: :booking
  has_one :customer, through: :booking

  enum :status, { issued: 0, paid: 1, overdue: 2, cancelled: 3 }

  before_create :generate_invoice_number

  def provider
    booking.service.provider
  end

  private

  def generate_invoice_number
    self.invoice_number ||= "INV-#{Date.current.strftime('%Y%m')}-#{SecureRandom.hex(3).upcase}"
  end
end
