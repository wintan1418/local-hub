class ServicePackage < ApplicationRecord
  belongs_to :service
  has_many :bookings, foreign_key: :service_package_id, dependent: :nullify

  validates :name, :price, presence: true
  validates :price, numericality: { greater_than: 0 }

  default_scope { order(:sort_order, :price) }
end
