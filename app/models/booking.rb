class Booking < ApplicationRecord
  belongs_to :customer, class_name: "User"
  belongs_to :service
  has_one :review, dependent: :destroy

  enum :status, { pending: 0, confirmed: 1, completed: 2, cancelled: 3 }
  validates :scheduled_at, :total_price, presence: true

  # Callbacks for automatic emails and notifications
  after_create :send_booking_notifications
  after_update :send_booking_update_notifications, if: :saved_change_to_status?

  private

  def send_booking_notifications
    # Send confirmation email to customer
    UserMailer.booking_confirmation(self).deliver_later
    
    # Send new booking notification to provider
    UserMailer.new_booking_notification(self).deliver_later
    
    # Create notifications
    Notification.create_for_booking(self, :created)
  end

  def send_booking_update_notifications
    # Send update email to customer
    UserMailer.booking_update(self).deliver_later
    
    # Create notification
    case status
    when 'confirmed'
      Notification.create_for_booking(self, :updated, "Your booking has been confirmed!")
    when 'completed'
      Notification.create_for_booking(self, :updated, "Your booking has been completed. Please leave a review!")
    when 'cancelled'
      Notification.create_for_booking(self, :cancelled)
    end
  end
end
