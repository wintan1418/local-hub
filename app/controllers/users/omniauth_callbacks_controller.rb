class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user&.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
    else
      session["devise.google_data"] = request.env["omniauth.auth"].except(:extra)
      errors = @user&.errors&.full_messages&.join(", ") || "Unknown error"
      Rails.logger.error "OmniAuth failure: #{errors}"
      redirect_to new_user_registration_url, alert: "Could not sign in with Google: #{errors}"
    end
  end

  def failure
    redirect_to new_user_session_path, alert: "Authentication failed. Please try again."
  end
end
