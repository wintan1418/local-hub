class ServiceArea < ApplicationRecord
  belongs_to :service
  validates :city, :state, :zip, :radius, presence: true
end
