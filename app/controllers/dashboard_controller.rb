class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    redirect_to after_sign_in_path_for(current_user)
  end
end
