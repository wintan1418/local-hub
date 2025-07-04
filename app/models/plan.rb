class Plan < ApplicationRecord
  # Associations
  has_many :subscriptions
  
  # Enums
  enum :billing_period, { monthly: 0, yearly: 1 }, default: :monthly
  
  # Validations
  validates :name, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  # Scopes
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position, :price) }
  
  # Features stored as JSON (Rails 8 handles JSON columns automatically)
  
  # Methods
  def display_price
    if price == 0
      "Free"
    else
      "$#{price.to_i}/#{billing_period == 'monthly' ? 'month' : 'year'}"
    end
  end
  
  def feature_list
    return [] if features.blank?
    case features
    when Array
      features
    when String
      features.split(',').map(&:strip)
    else
      []
    end
  end
end