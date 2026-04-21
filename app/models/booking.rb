class Booking < ApplicationRecord
  belongs_to :customer, class_name: "User"
  belongs_to :service
  has_one :review, dependent: :destroy
  has_one :invoice, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_one :dispute, dependent: :destroy
  belongs_to :service_package, optional: true
  has_many_attached :photos

  def total_expenses
    expenses.sum(:amount)
  end

  def profit
    total_price - total_expenses
  end

  enum :status, { pending: 0, confirmed: 1, completed: 2, cancelled: 3 }
  enum :recurrence, { one_time: 0, weekly: 1, biweekly: 2, monthly: 3 }, prefix: true, default: :one_time

  belongs_to :parent_booking, class_name: "Booking", optional: true
  has_many :recurring_children, class_name: "Booking", foreign_key: :parent_booking_id

  def recurring?
    !recurrence_one_time?
  end

  def next_occurrence_date
    return nil unless recurring?
    case recurrence.to_s
    when "weekly" then scheduled_at + 1.week
    when "biweekly" then scheduled_at + 2.weeks
    when "monthly" then scheduled_at + 1.month
    end
  end
  validates :scheduled_at, :total_price, presence: true
  validate :within_provider_availability, on: :create, unless: :skip_availability_check
  attr_accessor :skip_availability_check

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
    # Email to customer
    UserMailer.booking_confirmation(self).deliver_later

    # Email to provider
    UserMailer.new_booking_notification(self).deliver_later

    # In-app notification
    Notification.create_for_booking(self, :created)

    # SMS to customer if phone + pref enabled
    send_sms_safe(customer, TwilioService.method(:send_booking_confirmation), self)
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
    UserMailer.booking_update(self).deliver_later

    case status
    when 'confirmed'
      Notification.create_for_booking(self, :updated, "Your booking has been confirmed!")
      send_sms_safe(customer, ->(b) { TwilioService.send_sms(b.customer.phone, "Your booking for #{b.service.title} has been confirmed!", "booking_confirmed", b.customer) }, self)
    when 'completed'
      Notification.create_for_booking(self, :updated, "Your booking has been completed. Please leave a review!")
      generate_invoice
      send_sms_safe(customer, ->(b) { TwilioService.send_sms(b.customer.phone, "Your booking for #{b.service.title} is complete. Leave a review: #{Rails.application.routes.url_helpers.new_booking_review_url(b, host: ENV['APP_HOST'] || 'localhost:3000')}", "booking_completed", b.customer) }, self)
      RecurringBookingJob.perform_later(id) if recurring?
    when 'cancelled'
      Notification.create_for_booking(self, :cancelled)
    end
  end

  def send_sms_safe(user, method_or_proc, arg)
    return unless user.phone.present?
    return unless user.notification_preference&.sms_enabled != false
    method_or_proc.call(arg)
  rescue => e
    Rails.logger.error "SMS send failed: #{e.message}"
  end
end
