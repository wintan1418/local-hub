class Availability < ApplicationRecord
  belongs_to :service
  validates :day_of_week, :start_time, :end_time, presence: true
end
