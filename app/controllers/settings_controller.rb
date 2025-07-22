class SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notification_preference

  def index
    @user = current_user
    @notification_preference = @notification_preference
  end

  def update_profile
    @user = current_user

    if @user.update(user_params)
      redirect_to settings_path, notice: "Profile updated successfully!"
    else
      @notification_preference = @notification_preference
      render :index, status: :unprocessable_entity
    end
  end

  def update_notifications
    if @notification_preference.update(notification_params)
      redirect_to settings_path, notice: "Notification preferences updated successfully!"
    else
      @user = current_user
      render :index, status: :unprocessable_entity
    end
  end

  def update_password
    @user = current_user

    if @user.update_with_password(password_params)
      bypass_sign_in(@user)
      redirect_to settings_path, notice: "Password updated successfully!"
    else
      @notification_preference = @notification_preference
      render :index, status: :unprocessable_entity
    end
  end

  def delete_account
    @user = current_user

    if @user.valid_password?(params[:password])
      @user.destroy
      redirect_to root_path, notice: "Your account has been deleted successfully."
    else
      @notification_preference = @notification_preference
      flash.now[:alert] = "Incorrect password. Please try again."
      render :index, status: :unprocessable_entity
    end
  end

  private

  def set_notification_preference
    @notification_preference = NotificationPreference.for_user(current_user)
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone_number, :bio, :location, :website_url)
  end

  def notification_params
    params.require(:notification_preference).permit(
      :sms_enabled, :whatsapp_enabled, :email_enabled,
      :booking_reminders, :marketing_messages, :service_updates,
      :quiet_hours_start, :quiet_hours_end
    )
  end

  def password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
end
