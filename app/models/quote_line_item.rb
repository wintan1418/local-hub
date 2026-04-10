class QuoteLineItem < ApplicationRecord
  belongs_to :quote
  validates :description, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def total
    (quantity || 1) * (unit_price || 0)
  end
end
