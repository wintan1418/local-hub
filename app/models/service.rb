class Service < ApplicationRecord
  belongs_to :provider, class_name: 'User'
  belongs_to :category
  has_many :service_areas, dependent: :destroy
  has_many :availabilities, dependent: :destroy
  has_many :bookings, dependent: :destroy

  validates :title, :description, :price_type, :base_price, presence: true

  enum :price_type, { fixed: 0, hourly: 1, custom: 2 }
end
