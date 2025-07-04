class OnboardingController < ApplicationController
  before_action :authenticate_user!
  before_action :check_if_profile_complete

  def welcome
    @user = current_user
  end

  def update_profile
    @user = current_user

    if @user.update(onboarding_params)
      if @user.provider?
        redirect_to provider_profile_path, notice: 'Welcome! Your profile has been created.'
      else
        redirect_to customer_dashboard_path, notice: 'Welcome! Your profile has been created.'
      end
    else
      render :welcome, status: :unprocessable_entity
    end
  end

  private

  def check_if_profile_complete
    if current_user.profile_complete?
      redirect_to after_sign_in_path_for(current_user)
    end
  end

  def onboarding_params
    if current_user.provider?
      params.require(:user).permit(
        :first_name, :last_name, :phone, :bio,
        :business_name, :address, :city, :state, :zip_code,
        :profile_picture
      )
    else
      params.require(:user).permit(
        :first_name, :last_name, :phone, :profile_picture
      )
    end
  end
end
