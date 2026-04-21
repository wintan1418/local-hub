class ProviderSitesController < ApplicationController
  layout "provider_site"

  def show
    @provider = User.provider.where(site_published: true).find_by!(slug: params[:slug])
    @services = @provider.services.includes(:category)
    @reviews = Review.joins(booking: :service).where(services: { provider_id: @provider.id }).includes(booking: :customer).order(created_at: :desc).limit(6)
    @faqs = @provider.provider_faqs
    @brand_color = @provider.site_brand_color.presence || "#f97316"
  end
end
