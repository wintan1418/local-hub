class CreateCampaignRecipients < ActiveRecord::Migration[8.0]
  def change
    create_table :campaign_recipients do |t|
      t.references :crm_campaign, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status
      t.datetime :sent_at
      t.datetime :delivered_at
      t.string :error_message

      t.timestamps
    end
  end
end
