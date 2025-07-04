class CampaignRecipient < ApplicationRecord
  belongs_to :crm_campaign
  belongs_to :user
end
