class Conversation < ApplicationRecord
  belongs_to :customer, class_name: 'User'
  belongs_to :provider, class_name: 'User'
  has_many :chat_messages, dependent: :destroy

  enum :status, { active: 0, archived: 1, blocked: 2 }, default: :active

  validates :customer_id, uniqueness: { scope: :provider_id }
  validate :different_users

  scope :recent, -> { order(last_message_at: :desc) }
  scope :with_unread_for_user, ->(user) do
    if user.customer?
      where('unread_count_customer > 0')
    elsif user.provider?
      where('unread_count_provider > 0')
    end
  end

  def other_participant(current_user)
    current_user == customer ? provider : customer
  end

  def unread_count_for(user)
    if user == customer
      unread_count_customer
    elsif user == provider
      unread_count_provider
    else
      0
    end
  end

  def mark_as_read_for(user)
    if user == customer
      update(unread_count_customer: 0)
    elsif user == provider
      update(unread_count_provider: 0)
    end
  end

  def increment_unread_for(user)
    if user == customer
      increment!(:unread_count_provider)
    elsif user == provider
      increment!(:unread_count_customer)
    end
  end

  def last_message
    chat_messages.order(:created_at).last
  end

  private

  def different_users
    errors.add(:provider_id, "can't be the same as customer") if customer_id == provider_id
  end
end
