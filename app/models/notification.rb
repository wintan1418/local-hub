class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true, optional: true

  validates :title, presence: true
  validates :message, presence: true
  validates :notification_type, presence: true

  enum :notification_type, {
    booking_created: "booking_created",
    booking_updated: "booking_updated",
    booking_cancelled: "booking_cancelled",
    message_received: "message_received",
    payment_received: "payment_received",
    payment_failed: "payment_failed",
    subscription_created: "subscription_created",
    subscription_cancelled: "subscription_cancelled",
    review_received: "review_received",
    system_announcement: "system_announcement"
  }

  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def read?
    read_at.present?
  end

  def unread?
    !read?
  end

  def mark_as_read!
    update(read_at: Time.current)
  end

  def icon_class
    case notification_type
    when "booking_created", "booking_updated"
      "fas fa-calendar-plus text-blue-500"
    when "booking_cancelled"
      "fas fa-calendar-times text-red-500"
    when "message_received"
      "fas fa-comment text-green-500"
    when "payment_received"
      "fas fa-dollar-sign text-green-600"
    when "payment_failed"
      "fas fa-exclamation-triangle text-red-500"
    when "subscription_created"
      "fas fa-credit-card text-purple-500"
    when "subscription_cancelled"
      "fas fa-times-circle text-orange-500"
    when "review_received"
      "fas fa-star text-yellow-500"
    when "system_announcement"
      "fas fa-bullhorn text-blue-600"
    else
      "fas fa-bell text-gray-500"
    end
  end

  def background_class
    case notification_type
    when "booking_created", "booking_updated", "payment_received", "subscription_created", "review_received"
      "bg-green-50 border-green-200"
    when "message_received"
      "bg-blue-50 border-blue-200"
    when "booking_cancelled", "payment_failed"
      "bg-red-50 border-red-200"
    when "subscription_cancelled"
      "bg-orange-50 border-orange-200"
    when "system_announcement"
      "bg-purple-50 border-purple-200"
    else
      "bg-gray-50 border-gray-200"
    end
  end

  def self.create_for_booking(booking, type, custom_message = nil)
    case type
    when :created
      create_booking_notification(booking, "booking_created", "New Booking Received",
                                custom_message || "You have a new booking for #{booking.service.title}")
    when :updated
      create_booking_notification(booking, "booking_updated", "Booking Updated",
                                custom_message || "Your booking for #{booking.service.title} has been updated")
    when :cancelled
      create_booking_notification(booking, "booking_cancelled", "Booking Cancelled",
                                custom_message || "Your booking for #{booking.service.title} has been cancelled")
    end
  end

  def self.create_for_message(message)
    # Notify the recipient of the conversation
    recipient = message.conversation.other_participant(message.sender)

    create!(
      user: recipient,
      notifiable: message,
      notification_type: "message_received",
      title: "New Message",
      message: "#{message.sender.display_name} sent you a message: #{message.content.truncate(50)}"
    )
  end

  def self.create_for_payment(subscription, success = true)
    if success
      create!(
        user: subscription.user,
        notifiable: subscription,
        notification_type: "payment_received",
        title: "Payment Successful",
        message: "Your payment for #{subscription.plan.name} has been processed successfully"
      )
    else
      create!(
        user: subscription.user,
        notifiable: subscription,
        notification_type: "payment_failed",
        title: "Payment Failed",
        message: "Your payment for #{subscription.plan.name} could not be processed. Please update your payment method."
      )
    end
  end

  def self.create_system_announcement(title, message, users = User.all)
    users.find_each do |user|
      create!(
        user: user,
        notification_type: "system_announcement",
        title: title,
        message: message
      )
    end
  end

  private

  def self.create_booking_notification(booking, type, title, message)
    # Notify service provider
    if booking.service.user != booking.user
      create!(
        user: booking.service.user,
        notifiable: booking,
        notification_type: type,
        title: title,
        message: message
      )
    end

    # Notify customer (for updates/cancellations)
    if type != "booking_created" && booking.user != booking.service.user
      create!(
        user: booking.user,
        notifiable: booking,
        notification_type: type,
        title: title,
        message: message
      )
    end
  end
end
