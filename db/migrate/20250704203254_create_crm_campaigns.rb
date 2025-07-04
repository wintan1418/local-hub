class CreateCrmCampaigns < ActiveRecord::Migration[8.0]
  def change
    create_table :crm_campaigns do |t|
      t.string :name
      t.text :description
      t.string :campaign_type
      t.string :status
      t.string :target_audience
      t.text :message_template
      t.datetime :scheduled_at
      t.integer :sent_count
      t.integer :success_count
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
