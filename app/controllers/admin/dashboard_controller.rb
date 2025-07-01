module Admin
  class DashboardController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_admin!

    def index
      # TODO: Add admin dashboard logic
    end

    private

    def ensure_admin!
      redirect_to root_path, alert: 'Access denied.' unless current_user&.user_role == 'admin'
    end
  end
end 