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
                                 .limit(40)
                                 .pluck("services.provider_id")
                                 .uniq
                                 .first(8)
    @recently_active = User.provider
                           .where(id: recently_active_ids)
                           .includes(profile_picture_attachment: :blob)
                           .index_by(&:id)
                           .values_at(*recently_active_ids)
                           .compact

    # Backfill if fewer than 8 active — pad with newest providers not in featured
    if @recently_active.length < 8
      need = 8 - @recently_active.length
      have_ids = top_ids + @recently_active.map(&:id)
      filler = User.provider
                   .where.not(id: have_ids)
                   .includes(profile_picture_attachment: :blob)
                   .order(created_at: :desc)
                   .limit(need)
      @recently_active += filler.to_a
    end
    @plans = Plan.where(active: true).order(:position)
  end
end
