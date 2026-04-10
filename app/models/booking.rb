class Booking < ApplicationRecord
  belongs_to :customer, class_name: "User"
  belongs_to :service
  has_one :review, dependent: :destroy
  has_one :invoice, dependent: :destroy

  enum :status, { pending: 0, confirmed: 1, completed: 2, cancelled: 3 }
  validates :scheduled_at, :total_price, presence: true
  validate :within_provider_availability, on: :create

  def within_provider_availability
    return unless scheduled_at.present? && service.present?
    unless service.available_on?(scheduled_at)
      errors.add(:scheduled_at, "is outside the provider's available hours")
    end
  end

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

  def generate_invoice
    return if invoice.present?
    Invoice.create!(
      booking: self,
      amount: total_price,
      status: paid? ? :paid : :issued,
      issued_at: Time.current,
      paid_at: paid? ? Time.current : nil
    )
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
      generate_invoice
    when 'cancelled'
      Notification.create_for_booking(self, :cancelled)
    end
  end
end
