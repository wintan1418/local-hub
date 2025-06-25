class Category < ApplicationRecord
  has_many :services, dependent: :destroy
  validates :name, :slug, presence: true, uniqueness: true
end
