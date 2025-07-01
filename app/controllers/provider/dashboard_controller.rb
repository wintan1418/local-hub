module Provider
  class DashboardController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_provider!

    def index
      # TODO: Add provider dashboard logic
    end

    private

    def ensure_provider!
      redirect_to root_path, alert: 'Access denied.' unless current_user&.user_role == 'provider'
    end
  end
end 