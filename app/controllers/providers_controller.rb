class ProvidersController < ApplicationController
  before_action :authenticate_user!, only: [:favorite, :unfavorite]

  def show
    @provider = User.provider.find(params[:id])
    @services = @provider.services.includes(:category)
    @reviews = Review.joins(booking: :service).where(services: { provider_id: @provider.id }).includes(booking: [:customer, :service]).order(created_at: :desc).limit(10)
    @badge = @provider.provider_badge
    @is_favorited = current_user && Favorite.exists?(customer_id: current_user.id, provider_id: @provider.id)
  end

  def favorite
    @provider = User.provider.find(params[:id])
    Favorite.find_or_create_by(customer_id: current_user.id, provider_id: @provider.id)
    redirect_to provider_path(@provider), notice: "Added to My Pros"
  end

  def unfavorite
    @provider = User.provider.find(params[:id])
    Favorite.where(customer_id: current_user.id, provider_id: @provider.id).destroy_all
    redirect_to provider_path(@provider), notice: "Removed from My Pros"
  end
end
