class Admin::VerificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_verification_admin
  
  def index
    @pending_verifications = User.provider
                                .where(verified: false)
                                .where(business_license_document: true,
                                      insurance_certificate_document: true,
                                      professional_certifications_document: true,
                                      government_id_document: true)
                                .order(updated_at: :desc)
    
    @verified_users = User.provider.where(verified: true).order(verified_at: :desc).limit(10)
  end

  def show
    @provider = User.provider.find(params[:id])
  end

  def approve
    @provider = User.provider.find(params[:id])
    
    if @provider.verification_documents_uploaded?
      @provider.update(
        verified: true,
        verified_at: Time.current
      )
      
      # Send notification to provider
      # ProviderMailer.verification_approved(@provider).deliver_later
      
      redirect_to admin_verifications_path, 
                  notice: "#{@provider.business_name} has been successfully verified."
    else
      redirect_to admin_verification_path(@provider),
                  alert: "Cannot verify provider - missing required documents."
    end
  end

  def reject
    @provider = User.provider.find(params[:id])
    rejection_reason = params[:rejection_reason]
    
    @provider.update(verified: false, verified_at: nil)
    
    # Reset document flags if needed to request re-upload
    if params[:reset_documents]
      @provider.update(
        business_license_document: false,
        insurance_certificate_document: false,
        professional_certifications_document: false,
        government_id_document: false
      )
      
      # Purge old documents
      @provider.business_license_file.purge if @provider.business_license_file.attached?
      @provider.insurance_certificate_file.purge if @provider.insurance_certificate_file.attached?
      @provider.professional_certifications_file.purge if @provider.professional_certifications_file.attached?
      @provider.government_id_file.purge if @provider.government_id_file.attached?
    end
    
    # Send notification to provider
    # ProviderMailer.verification_rejected(@provider, rejection_reason).deliver_later
    
    redirect_to admin_verifications_path, 
                notice: "Verification rejected for #{@provider.business_name}."
  end

  private

  def ensure_verification_admin
    unless current_user.can_manage_verifications?
      redirect_to root_path, alert: "Access denied. Verification admin privileges required."
    end
  end
end