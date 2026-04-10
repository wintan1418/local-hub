class Quote < ApplicationRecord
  belongs_to :service
  belongs_to :customer, class_name: "User"
  belongs_to :provider, class_name: "User"
  has_many :line_items, class_name: "QuoteLineItem", dependent: :destroy
  accepts_nested_attributes_for :line_items, reject_if: :all_blank, allow_destroy: true

  enum :status, { draft: 0, sent: 1, approved: 2, rejected: 3, expired: 4, converted: 5 }

  validates :title, presence: true
  validates :total_price, presence: true, numericality: { greater_than: 0 }

  before_validation :calculate_total

  def convert_to_booking!
    return unless approved?

    booking = Booking.create!(
      customer: customer,
      service: service,
      scheduled_at: Time.current + 3.days,
      total_price: total_price,
      status: :pending
    )
    update!(status: :converted)
    booking
  end

  private

  def calculate_total
    if line_items.any?
      self.total_price = line_items.reject(&:marked_for_destruction?).sum { |li| (li.quantity || 1) * (li.unit_price || 0) }
    end
  end
end
