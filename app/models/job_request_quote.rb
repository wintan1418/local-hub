class JobRequestQuote < ApplicationRecord
  belongs_to :job_request
  belongs_to :provider, class_name: "User"

  enum :status, { pending: 0, accepted: 1, declined: 2 }

  validates :price, :message, presence: true
  validates :price, numericality: { greater_than: 0 }
end
