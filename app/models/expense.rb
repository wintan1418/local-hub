class Expense < ApplicationRecord
  belongs_to :booking

  validates :description, :amount, presence: true
  validates :amount, numericality: { greater_than: 0 }

  CATEGORIES = %w[materials labor travel supplies equipment other].freeze
end
