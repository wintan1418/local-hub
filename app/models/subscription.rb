class Subscription < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :plan
  
  # Enums
  enum :status, { 
    trialing: 0,
    active: 1, 
    past_due: 2,
    canceled: 3,
    unpaid: 4,
    incomplete: 5
  }, default: :trialing
  
  # Validations
  validates :user_id, uniqueness: { scope: :status, 
    conditions: -> { where.not(status: [:canceled]) },
    message: "already has an active subscription" 
  }
  
  # Scopes
  scope :active_or_trialing, -> { where(status: [:active, :trialing]) }
  scope :current, -> { active_or_trialing.where("current_period_end > ?", Time.current) }
  
  # Callbacks
  before_create :set_trial_period
  
  # Methods
  def active?
    (status == 'active' || status == 'trialing') && current_period_end > Time.current
  end
  
  def expired?
    current_period_end < Time.current
  end
  
  def days_until_renewal
    return 0 if expired?
    ((current_period_end - Time.current) / 1.day).ceil
  end
  
  def cancel_subscription
    update(cancel_at_period_end: true, status: :canceled)
  end
  
  private
  
  def set_trial_period
    if plan.price == 0 # Free plan
      self.current_period_start = Time.current
      self.current_period_end = 100.years.from_now
      self.status = :active
    else
      self.current_period_start = Time.current
      self.current_period_end = 14.days.from_now # 14 day trial
      self.status = :trialing
    end
  end
end
