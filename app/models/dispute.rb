class Dispute < ApplicationRecord
  belongs_to :booking
  belongs_to :raised_by, class_name: "User"

  enum :status, { open: 0, under_review: 1, resolved: 2, dismissed: 3, refunded: 4 }

  REASONS = [
    "Service not delivered",
    "Quality issue",
    "Provider no-show",
    "Overcharged",
    "Damaged property",
    "Wrong service",
    "Other"
  ].freeze

  validates :reason, :description, presence: true
end
