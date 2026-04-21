class JobRequest < ApplicationRecord
  belongs_to :customer, class_name: "User"
  belongs_to :category
  has_many :quotes, class_name: "JobRequestQuote", dependent: :destroy

  enum :status, { open: 0, closed: 1, awarded: 2, cancelled: 3 }

  validates :title, :description, presence: true
end
