class FavoritesController < ApplicationController
  before_action :authenticate_user!

  def index
    @providers = current_user.favorited_providers
                             .includes(:services, :reviews, profile_picture_attachment: :blob)
                             .distinct
  end
end
