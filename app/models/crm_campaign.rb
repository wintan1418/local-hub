class CrmCampaign < ApplicationRecord
  belongs_to :user # The admin/provider who created the campaign
  has_many :campaign_recipients, dependent: :destroy
  has_many :recipients, through: :campaign_recipients, source: :user

  enum :campaign_type, {
    sms: 0,
    whatsapp: 1,
    email: 2,
    multi_channel: 3
  }, default: :sms

  enum :status, {
    draft: 0,
    scheduled: 1,
    in_progress: 2,
    completed: 3,
    cancelled: 4,
    failed: 5
  }, default: :draft

  enum :target_audience, {
    all_customers: 0,
    all_providers: 1,
    active_customers: 2,
    inactive_customers: 3,
    new_users: 4,
    custom_segment: 5
  }, default: :all_customers

  validates :name, presence: true
  validates :message_template, presence: true

  scope :active, -> { where(status: [ :scheduled, :in_progress ]) }
  scope :completed, -> { where(status: :completed) }

  def can_send?
    [ :draft, :scheduled ].include?(status.to_sym)
  end

  def success_rate
    return 0 if sent_count.to_i == 0
    (success_count.to_f / sent_count * 100).round(2)
  end

  def personalize_message(user)
    template = message_template.dup
    template.gsub!("{{first_name}}", user.first_name || "Customer")
    template.gsub!("{{last_name}}", user.last_name || "")
    template.gsub!("{{full_name}}", user.full_name || user.email.split("@").first)
    template.gsub!("{{business_name}}", user.business_name || "")
    template
  end
end
