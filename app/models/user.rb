class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :user_role, { customer: 0, provider: 1, admin: 2 }
  validates :user_role, presence: true

  # Associations
  has_many :services, foreign_key: :provider_id, dependent: :destroy
  has_many :bookings, foreign_key: :customer_id, dependent: :destroy
  has_many :messages_sent, class_name: 'Message', foreign_key: :sender_id, dependent: :destroy
  has_many :messages_received, class_name: 'Message', foreign_key: :recipient_id, dependent: :destroy
  # If you want reviews written by this user (as customer), you can add:
  # has_many :reviews, through: :bookings
end
