class HomeController < ApplicationController
  def index
    @categories = Category.order(:name)
    @total_providers = User.provider.count
    @total_customers = User.customer.count
    @total_services = Service.count
    @total_bookings = Booking.count
    @featured_services = Service.includes(:provider, :category)
                                .order(created_at: :desc)
                                .limit(6)
    @top_providers = User.provider
                         .includes(profile_picture_attachment: :blob)
                         .select { |p| p.total_completed_bookings >= 1 }
                         .sort_by { |p| [ -p.average_rating, -p.total_completed_bookings ] }
                         .first(4)

    # Recently active — providers with the most recent booking activity
    top_ids = @top_providers.map(&:id)
    recently_active_ids = Booking.joins(:service)
                                 .where.not(services: { provider_id: top_ids })
                                 .order(created_at: :desc)
                                 .limit(20)
                                 .pluck("services.provider_id")
                                 .uniq
                                 .first(4)
    @recently_active = User.provider
                           .where(id: recently_active_ids)
                           .includes(profile_picture_attachment: :blob)
                           .index_by(&:id)
                           .values_at(*recently_active_ids)
                           .compact
    @plans = Plan.where(active: true).order(:position)
  end
end
