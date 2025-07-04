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

    if params[:verification_documents].present?
      params[:verification_documents].each do |document|
        @user.verification_documents.attach(document)
      end
      redirect_to verification_provider_profile_path, notice: "Documents uploaded successfully. We will review them shortly."
    else
      redirect_to verification_provider_profile_path, alert: "Please select documents to upload."
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
