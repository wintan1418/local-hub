class Review < ApplicationRecord
  belongs_to :booking
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :comment, presence: true, length: { minimum: 10, message: "must be at least 10 characters" }

  after_create :notify_provider

  private

  def notify_provider
    UserMailer.new_review_notification(self).deliver_later
  end
end
