class Message < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  belongs_to :booking
  validates :content, presence: true
  validates :read, inclusion: { in: [true, false] }
end
