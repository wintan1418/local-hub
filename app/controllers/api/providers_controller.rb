class Api::ProvidersController < ApplicationController
  before_action :authenticate_user!

  def index
    @providers = User.provider.includes(:profile_picture_attachment)

    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @providers = @providers.where(
        "first_name ILIKE ? OR last_name ILIKE ? OR business_name ILIKE ? OR email ILIKE ?",
        search_term, search_term, search_term, search_term
      )
    end

    @providers = @providers.limit(20)

    render json: @providers.map { |provider|
      {
        id: provider.id,
        display_name: provider.display_name,
        business_name: provider.business_name,
        email: provider.email,
        average_rating: provider.average_rating,
        total_reviews: provider.total_reviews,
        profile_picture_url: provider.profile_picture.attached? ?
          url_for(provider.profile_picture.variant(resize_to_fill: [ 100, 100 ])) : nil
      }
    }
  end
end
