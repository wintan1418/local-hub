class Provider::ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_provider

  def show
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(profile_params)
      redirect_to provider_profile_path, notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def verification
    @user = current_user
    @verification_documents = @user.verification_documents
  end

  def upload_documents
    @user = current_user
    uploaded_count = 0
    errors = []

    # Handle individual document uploads
    if params[:business_license_file].present?
      @user.business_license_file.attach(params[:business_license_file])
      @user.update(business_license_document: true)
      uploaded_count += 1
    end

    if params[:insurance_certificate_file].present?
      @user.insurance_certificate_file.attach(params[:insurance_certificate_file])
      @user.update(insurance_certificate_document: true)
      uploaded_count += 1
    end

    if params[:professional_certifications_file].present?
      @user.professional_certifications_file.attach(params[:professional_certifications_file])
      @user.update(professional_certifications_document: true)
      uploaded_count += 1
    end

    if params[:government_id_file].present?
      @user.government_id_file.attach(params[:government_id_file])
      @user.update(government_id_document: true)
      uploaded_count += 1
    end

    if uploaded_count > 0
      # Send verification pending email
      UserMailer.verification_pending(@user).deliver_later

      # Create notification for admins
      admin_users = User.where(user_role: 'admin')
      admin_users.each do |admin|
        Notification.create!(
          user: admin,
          title: "New verification submission",
          message: "#{@user.display_name} has submitted verification documents for review.",
          notification_type: "system_announcement"
        )
      end

      notice_message = "#{uploaded_count} document(s) uploaded successfully. We will review them shortly."
      redirect_to verification_provider_profile_path, notice: notice_message
    else
      redirect_to verification_provider_profile_path, alert: "Please select at least one document to upload."
    end
  end

  def portfolio
    @user = current_user
    @portfolio_images = @user.portfolio_images
  end

  def upload_portfolio
    @user = current_user

    if params[:portfolio_images].present?
      params[:portfolio_images].each do |image|
        @user.portfolio_images.attach(image)
      end
      redirect_to portfolio_provider_profile_path, notice: "Portfolio images uploaded successfully."
    else
      redirect_to portfolio_provider_profile_path, alert: "Please select images to upload."
    end
  end

  def destroy_portfolio_image
    @image = current_user.portfolio_images.find(params[:image_id])
    @image.purge
    redirect_to portfolio_provider_profile_path, notice: "Image removed successfully."
  end

  private

  def ensure_provider
    redirect_to root_path, alert: "Access denied." unless current_user.provider?
  end

  def profile_params
    params.require(:user).permit(
      :first_name, :last_name, :phone, :bio,
      :business_name, :business_license, :insurance_number,
      :years_experience, :address, :city, :state, :zip_code,
      :profile_picture
    )
  end
end
