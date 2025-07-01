class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:user_role])
    devise_parameter_sanitizer.permit(:account_update, keys: [:user_role])
  end

  def after_sign_in_path_for(resource)
    case resource.user_role
    when "customer"
      customer_dashboard_path
    when "provider"
      provider_dashboard_path
    when "admin"
      admin_dashboard_path
    else
      root_path
    end
  end

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end
end
