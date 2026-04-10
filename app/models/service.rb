class Service < ApplicationRecord
  belongs_to :provider, class_name: "User"
  belongs_to :category
  has_many :service_areas, dependent: :destroy
  has_many :availabilities, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :reviews, through: :bookings

  has_many_attached :images

  validates :title, :description, :price_type, :base_price, presence: true

  enum :price_type, { fixed: 0, hourly: 1, custom: 2 }

  def available_on?(datetime)
    return true if availabilities.empty?
    day = datetime.wday # 0=Sunday
    avail = availabilities.find_by(day_of_week: day)
    return false unless avail
    time = datetime.strftime("%H:%M")
    time >= avail.start_time.strftime("%H:%M") && time <= avail.end_time.strftime("%H:%M")
  end

  def availability_text
    return "Flexible schedule" if availabilities.empty?
    days = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]
    availabilities.order(:day_of_week).map { |a|
      "#{days[a.day_of_week]}: #{a.start_time.strftime('%-I:%M %p')} - #{a.end_time.strftime('%-I:%M %p')}"
    }.join(", ")
  end
end
