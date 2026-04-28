class JobRequest < ApplicationRecord
  belongs_to :customer, class_name: "User"
  belongs_to :category
  has_many :quotes, class_name: "JobRequestQuote", dependent: :destroy

  enum :status, { open: 0, closed: 1, awarded: 2, cancelled: 3 }

  validates :title, :description, presence: true
  validates :budget_min, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :budget_max, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validate  :budget_range_valid
  validate  :needed_by_in_future, on: :create

  scope :open_requests, -> { where(status: :open).order(created_at: :desc) }

  private

  def budget_range_valid
    return if budget_min.blank? || budget_max.blank?
    if budget_min > budget_max
      errors.add(:budget_max, "must be greater than or equal to minimum budget")
    end
  end

  def needed_by_in_future
    return if needed_by.blank?
    if needed_by < Date.current
      errors.add(:needed_by, "must be today or later")
    end
  end
end
