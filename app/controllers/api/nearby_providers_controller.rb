class Api::NearbyProvidersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:index]

  def index
    lat = params[:lat].to_f
    lng = params[:lng].to_f
    radius = (params[:radius] || 25).to_i.clamp(1, 100)

    if lat.zero? || lng.zero?
      render json: { error: "Latitude and longitude required" }, status: :unprocessable_entity
      return
    end

    providers = User.provider
                    .where.not(latitude: nil)
                    .near([lat, lng], radius, order: :distance)
                    .includes(profile_picture_attachment: :blob)
                    .limit(8)

    render json: providers.map { |p|
      {
        id: p.id,
        display_name: p.display_name,
        business_name: p.business_name,
        city: p.city,
        state: p.state,
        average_rating: p.average_rating,
        total_reviews: p.total_reviews,
        total_completed_bookings: p.total_completed_bookings,
        badge: p.provider_badge,
        verified: p.verified?,
        distance: p.distance.round(1),
        profile_picture_url: p.profile_picture.attached? ?
          rails_blob_url(p.profile_picture, only_path: true) : nil,
        url: leaderboard_path(p)
      }
    }
  end
end
