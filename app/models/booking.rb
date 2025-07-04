class Booking < ApplicationRecord
  belongs_to :customer, class_name: "User"
  belongs_to :service
  has_one :review, dependent: :destroy

  enum :status, { pending: 0, confirmed: 1, completed: 2, cancelled: 3 }
  validates :scheduled_at, :total_price, presence: true
end
