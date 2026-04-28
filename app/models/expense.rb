class Expense < ApplicationRecord
  belongs_to :booking

  CATEGORIES = %w[materials labor travel supplies equipment other].freeze

  validates :description, :amount, presence: true
  validates :amount, numericality: { greater_than: 0 }
  validates :category, inclusion: { in: CATEGORIES, message: "must be one of: #{CATEGORIES.join(', ')}" }
end
