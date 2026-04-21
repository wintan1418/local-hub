class ProviderFaq < ApplicationRecord
  belongs_to :provider, class_name: "User"
  validates :question, :answer, presence: true
  default_scope { order(:sort_order, :id) }
end
