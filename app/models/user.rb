class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  enum :user_role, { customer: 0, provider: 1, admin: 2 }, default: :customer
  validates :user_role, presence: true

  # Associations
  has_many :services, foreign_key: :provider_id, dependent: :destroy
  has_many :bookings, foreign_key: :customer_id, dependent: :destroy
  has_many :messages_sent, class_name: "Message", foreign_key: :sender_id, dependent: :destroy
  has_many :messages_received, class_name: "Message", foreign_key: :recipient_id, dependent: :destroy
  # If you want reviews written by this user (as customer), you can add:
  # has_many :reviews, through: :bookings

  # Active Storage associations
  has_one_attached :profile_picture
  has_many_attached :verification_documents
  has_many_attached :portfolio_images

  # Subscription
  has_one :subscription, -> { current }
  has_many :subscriptions

  # Chat
  has_many :customer_conversations, class_name: "Conversation", foreign_key: "customer_id", dependent: :destroy
  has_many :provider_conversations, class_name: "Conversation", foreign_key: "provider_id", dependent: :destroy
  has_many :sent_messages, class_name: "ChatMessage", foreign_key: "sender_id", dependent: :destroy

  # Notifications
  has_many :notifications, dependent: :destroy

  # CRM
  has_many :phone_verifications, dependent: :destroy
  has_one :notification_preference, dependent: :destroy
  has_many :sms_logs, dependent: :destroy
  has_many :crm_campaigns, dependent: :destroy
  has_many :campaign_recipients, dependent: :destroy

  # Email confirmation token
  has_secure_token :email_confirmation_token
  has_secure_token :password_reset_token

  # Validations
  validates :first_name, presence: true, if: :profile_required?
  validates :last_name, presence: true, if: :profile_required?
  validates :phone, presence: true, format: { with: /\A\d{10,15}\z/ }, if: :profile_required?
  validates :business_name, presence: true, if: :provider_profile_required?
  validates :address, presence: true, if: :provider_profile_required?
  validates :city, presence: true, if: :provider_profile_required?
  validates :state, presence: true, if: :provider_profile_required?
  validates :zip_code, presence: true, format: { with: /\A\d{5}\z/ }, if: :provider_profile_required?

  # Scopes
  scope :verified, -> { where(verified: true) }
  scope :unverified, -> { where(verified: false) }

  # Instance methods
  def full_name
    "#{first_name} #{last_name}".strip
  end

  def display_name
    full_name.presence || email.split("@").first
  end

  def complete_address
    [ address, city, state, zip_code ].compact.join(", ")
  end

  def profile_complete?
    return false unless first_name.present? && last_name.present? && phone.present?

    if provider?
      business_name.present? && address.present? && city.present? && state.present? && zip_code.present?
    else
      true
    end
  end

  def verification_status
    if verified?
      "Verified on #{verified_at.strftime('%B %d, %Y')}"
    else
      "Not verified"
    end
  end

  def has_active_subscription?
    subscription.present? && subscription.active?
  end

  def subscribed?
    has_active_subscription?
  end

  def subscription_plan
    subscription&.plan
  end

  def can_create_service?
    customer? || (provider? && has_active_subscription?)
  end

  def conversations
    if customer?
      customer_conversations
    elsif provider?
      provider_conversations
    else
      Conversation.none
    end
  end

  def conversation_with(other_user)
    if customer?
      customer_conversations.find_by(provider: other_user)
    elsif provider?
      provider_conversations.find_by(customer: other_user)
    end
  end

  def total_unread_messages
    conversations.sum do |conv|
      conv.unread_count_for(self)
    end
  end

  def unread_notifications_count
    notifications.unread.count
  end

  def total_unread_count
    unread_notifications_count + total_unread_messages
  end

  # Provider statistics and ratings
  def average_rating
    return 0 unless provider?
    reviews = Review.joins(booking: :service).where(services: { provider_id: id })
    return 0 if reviews.empty?
    (reviews.average(:rating) || 0).round(1)
  end

  def total_reviews
    return 0 unless provider?
    Review.joins(booking: :service).where(services: { provider_id: id }).count
  end

  def total_completed_bookings
    return 0 unless provider?
    Booking.joins(:service).where(services: { provider_id: id }, status: "completed").count
  end

  def total_revenue
    return 0 unless provider?
    Booking.joins(:service).where(services: { provider_id: id }, status: "completed").sum(:total_price) || 0
  end

  def completion_rate
    total_bookings = Booking.joins(:service).where(services: { provider_id: id }).count
    return 0 if total_bookings == 0
    (total_completed_bookings.to_f / total_bookings * 100).round(1)
  end

  def provider_badge
    return nil unless provider?

    rating = average_rating
    completed = total_completed_bookings

    case
    when rating >= 4.8 && completed >= 50
      { name: "Elite", color: "purple", icon: "fas fa-crown" }
    when rating >= 4.5 && completed >= 25
      { name: "Professional", color: "blue", icon: "fas fa-star" }
    when rating >= 4.0 && completed >= 10
      { name: "Trusted", color: "green", icon: "fas fa-shield-alt" }
    when completed >= 5
      { name: "Active", color: "yellow", icon: "fas fa-thumbs-up" }
    else
      { name: "New", color: "gray", icon: "fas fa-seedling" }
    end
  end

  private

  def profile_required?
    persisted? && created_at && (created_at < 1.day.ago || provider?)
  end

  def provider_profile_required?
    provider? && persisted? && created_at && created_at < 1.hour.ago
  end

  def send_welcome_email
    UserMailer.welcome_email(self).deliver_later
  end

  def send_confirmation_email
    regenerate_email_confirmation_token
    UserMailer.confirmation_instructions(self, email_confirmation_token).deliver_later
  end

  def send_password_reset_email
    regenerate_password_reset_token
    UserMailer.password_reset_instructions(self, password_reset_token).deliver_later
  end

  def confirm_email!
    update(
      confirmed_at: Time.current,
      email_confirmation_token: nil
    )
  end

  def email_confirmed?
    confirmed_at.present?
  end

  def password_reset_expired?
    return true if password_reset_token.blank?
    updated_at < 2.hours.ago
  end

  def reset_password!(new_password)
    update(
      password: new_password,
      password_reset_token: nil
    )
  end
end
