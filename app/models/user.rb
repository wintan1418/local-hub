class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Explicitly declare attribute types for Rails 8 support
  attribute :user_role, :integer, default: 0
  attribute :admin_role, :string
  
  enum :user_role, { customer: 0, provider: 1, admin: 2 }, default: :customer
  
  # Admin role constants
  ADMIN_ROLES = {
    'super_admin' => 'Super Admin',
    'verification_admin' => 'Verification Admin',
    'support_admin' => 'Support Admin',
    'content_admin' => 'Content Admin'
  }.freeze
  
  validates :admin_role, inclusion: { in: ADMIN_ROLES.keys }, allow_nil: true

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
  
  # Individual document attachments
  has_one_attached :business_license_file
  has_one_attached :insurance_certificate_file
  has_one_attached :professional_certifications_file
  has_one_attached :government_id_file

  # Subscription
  has_one :subscription, -> { current }
  has_many :subscriptions

  # Chat
  has_many :customer_conversations, class_name: "Conversation", foreign_key: "customer_id", dependent: :destroy
  has_many :provider_conversations, class_name: "Conversation", foreign_key: "provider_id", dependent: :destroy
  has_many :sent_messages, class_name: "ChatMessage", foreign_key: "sender_id", dependent: :destroy

  # Notifications
  has_many :notifications, dependent: :destroy

  # Callbacks for automatic emails
  after_create :send_welcome_email

  # CRM
  has_many :phone_verifications, dependent: :destroy
  has_one :notification_preference, dependent: :destroy
  has_many :sms_logs, dependent: :destroy
  has_many :crm_campaigns, dependent: :destroy
  has_many :campaign_recipients, dependent: :destroy


  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }, 
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
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
    elsif verification_documents_uploaded?
      "Under Review"
    else
      "Pending Verification"
    end
  end

  def verification_progress
    total_documents = 4
    uploaded_documents = [
      business_license_document?,
      insurance_certificate_document?,
      professional_certifications_document?,
      government_id_document?
    ].count(true)
    
    (uploaded_documents.to_f / total_documents * 100).round
  end

  def verification_documents_uploaded?
    business_license_document? &&
    insurance_certificate_document? &&
    professional_certifications_document? &&
    government_id_document?
  end

  def missing_documents
    documents = []
    documents << "Business License" unless business_license_document?
    documents << "Insurance Certificate" unless insurance_certificate_document?
    documents << "Professional Certifications" unless professional_certifications_document?
    documents << "Government ID" unless government_id_document?
    documents
  end

  # Admin role methods
  def super_admin?
    admin? && admin_role == 'super_admin'
  end

  def verification_admin?
    admin? && (admin_role == 'verification_admin' || admin_role == 'super_admin')
  end

  def support_admin?
    admin? && (admin_role == 'support_admin' || admin_role == 'super_admin')
  end

  def content_admin?
    admin? && (admin_role == 'content_admin' || admin_role == 'super_admin')
  end

  def admin_role_display
    ADMIN_ROLES[admin_role] || 'Admin'
  end

  def can_manage_verifications?
    verification_admin?
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

  def send_password_reset_email
    # Use Devise's built-in reset_password_token
    self.reset_password_token = Devise.friendly_token
    self.reset_password_sent_at = Time.current
    save(validate: false)
    UserMailer.password_reset_instructions(self, reset_password_token).deliver_later
  end

  def valid_email_domain?
    return false if email.blank?
    
    # List of common email providers and business domains
    allowed_domains = %w[
      gmail.com googlemail.com yahoo.com yahoo.co.uk hotmail.com hotmail.co.uk
      outlook.com outlook.co.uk live.com live.co.uk icloud.com me.com
      aol.com aol.co.uk protonmail.com protonmail.ch
    ]
    
    domain = email.split('@').last&.downcase
    return true if allowed_domains.include?(domain)
    
    # Allow business domains (domains with valid MX records)
    begin
      require 'resolv'
      mx_records = Resolv::DNS.open { |dns| dns.getresources(domain, Resolv::DNS::Resource::IN::MX) }
      mx_records.any?
    rescue
      false
    end
  end

  def disposable_email?
    return false if email.blank?
    
    # List of known disposable email domains
    disposable_domains = %w[
      10minutemail.com guerrillamail.com mailinator.com tempmail.org
      throwaway.email temp-mail.org getnada.com
    ]
    
    domain = email.split('@').last&.downcase
    disposable_domains.include?(domain)
  end

  def password_reset_expired?
    return true if reset_password_token.blank?
    reset_password_sent_at.nil? || reset_password_sent_at < 2.hours.ago
  end

  def reset_password!(new_password)
    update(
      password: new_password,
      reset_password_token: nil,
      reset_password_sent_at: nil
    )
  end

  private

end
