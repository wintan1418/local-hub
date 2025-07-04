class Provider::CrmCampaignsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_provider_or_admin
  before_action :set_campaign, only: [:show, :edit, :update, :destroy, :send_campaign, :cancel_campaign]
  
  def index
    @campaigns = current_user.crm_campaigns.includes(:recipients).order(created_at: :desc)
  end

  def new
    @campaign = current_user.crm_campaigns.build
  end

  def create
    @campaign = current_user.crm_campaigns.build(campaign_params)
    
    if @campaign.save
      redirect_to provider_crm_campaigns_path, notice: 'Campaign created successfully.'
    else
      render :new
    end
  end

  def show
    @recipients = @campaign.campaign_recipients.includes(:user)
  end

  def edit
  end

  def update
    if @campaign.update(campaign_params)
      redirect_to provider_crm_campaigns_path, notice: 'Campaign updated successfully.'
    else
      render :edit
    end
  end

  def destroy
    @campaign.destroy
    redirect_to provider_crm_campaigns_path, notice: 'Campaign deleted successfully.'
  end
  
  def send_campaign
    if @campaign.can_send?
      # This would typically be handled by a background job
      CampaignSenderJob.perform_later(@campaign)
      @campaign.update(status: :scheduled, scheduled_at: Time.current)
      redirect_to provider_crm_campaigns_path, notice: 'Campaign scheduled for sending.'
    else
      redirect_to provider_crm_campaigns_path, alert: 'Campaign cannot be sent in its current state.'
    end
  end
  
  def cancel_campaign
    if @campaign.update(status: :cancelled)
      redirect_to provider_crm_campaigns_path, notice: 'Campaign cancelled successfully.'
    else
      redirect_to provider_crm_campaigns_path, alert: 'Unable to cancel campaign.'
    end
  end
  
  private
  
  def set_campaign
    @campaign = current_user.crm_campaigns.find(params[:id])
  end
  
  def campaign_params
    params.require(:crm_campaign).permit(
      :name, :description, :campaign_type, :target_audience, 
      :message_template, :scheduled_at
    )
  end
  
  def ensure_provider_or_admin
    unless current_user.provider? || current_user.admin?
      redirect_to root_path, alert: 'Access denied. Providers and admins only.'
    end
  end
end