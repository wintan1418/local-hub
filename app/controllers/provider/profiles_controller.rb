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

    uploaded_count += attach_verification_document(:business_license_file, :business_license_document, errors)
    uploaded_count += attach_verification_document(:insurance_certificate_file, :insurance_certificate_document, errors)
    uploaded_count += attach_verification_document(:professional_certifications_file, :professional_certifications_document, errors)
    uploaded_count += attach_verification_document(:government_id_file, :government_id_document, errors)

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
    elsif errors.any?
      redirect_to verification_provider_profile_path, alert: errors.to_sentence
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
      invalid = params[:portfolio_images].reject { |image| valid_portfolio_image?(image) }

      if invalid.any?
        redirect_to portfolio_provider_profile_path, alert: "Portfolio images must be JPG, PNG, GIF, or WebP files under 10MB."
        return
      end

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
      :profile_picture, :vacation_until
    )
  end

  def attach_verification_document(param_name, flag_name, errors)
    upload = params[param_name]
    return 0 if upload.blank?

    unless valid_verification_document?(upload)
      errors << "#{param_name.to_s.humanize} must be a PDF, image, or Word document under 10MB."
      return 0
    end

    @user.public_send(param_name).attach(upload)
    @user.update(flag_name => true)
    1
  end

  def valid_verification_document?(upload)
    allowed_types = %w[
      application/pdf
      application/msword
      application/vnd.openxmlformats-officedocument.wordprocessingml.document
      image/jpeg
      image/png
      image/webp
    ]

    allowed_types.include?(upload.content_type) && upload.size <= 10.megabytes
  end

  def valid_portfolio_image?(upload)
    %w[image/jpeg image/png image/gif image/webp].include?(upload.content_type) && upload.size <= 10.megabytes
  end
end
