class Favorite < ApplicationRecord
  belongs_to :customer, class_name: "User"
  belongs_to :provider, class_name: "User"

  validates :customer_id, uniqueness: { scope: :provider_id }
end
