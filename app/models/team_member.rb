class TeamMember < ApplicationRecord
  belongs_to :provider, class_name: "User"
  belongs_to :member, class_name: "User", optional: true

  enum :status, { invited: 0, active: 1, removed: 2 }

  ROLES = %w[technician manager admin].freeze

  validates :role, inclusion: { in: ROLES }
  validates :invite_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  before_create :generate_invite_token

  private

  def generate_invite_token
    self.invite_token ||= SecureRandom.hex(16)
  end
end
