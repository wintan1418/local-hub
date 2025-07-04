class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:user_role])
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :user_role, :first_name, :last_name, :phone, :bio,
      :business_name, :business_license, :insurance_number,
      :years_experience, :address, :city, :state, :zip_code,
      :profile_picture
    ])
  end

  def after_sign_in_path_for(resource)
    # Check if profile is complete for new users
    if !resource.profile_complete? && (resource.first_name.blank? || resource.last_name.blank?)
      return onboarding_welcome_path
    end
    
    case resource.user_role
    when "customer"
      customer_dashboard_path
    when "provider"
      provider_dashboard_path
    when "admin"
      admin_dashboard_path
    else
      # Default to customer dashboard if user_role is nil or unknown
      customer_dashboard_path
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end
end
