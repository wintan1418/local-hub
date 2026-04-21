class FavoritesController < ApplicationController
  before_action :authenticate_user!

  def index
    @providers = current_user.favorited_providers.includes(:services)
  end
end
