class ProvidersController < ApplicationController
  def show
    @provider = User.provider.find(params[:id])
    @services = @provider.services.includes(:category)
    @reviews = Review.joins(booking: :service).where(services: { provider_id: @provider.id }).includes(booking: [:customer, :service]).order(created_at: :desc).limit(10)
    @badge = @provider.provider_badge
  end
end
