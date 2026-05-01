class HomeController < ApplicationController
  def index
    @categories = Category.left_joins(:services)
                          .select("categories.*, COUNT(services.id) AS services_count")
                          .group("categories.id")
                          .order(:name)
    @total_providers = User.provider.count
    @total_customers = User.customer.count
    @total_services = Service.count
    @total_bookings = Booking.count
    @featured_services = Service.includes(:provider, :category)
                                .order(created_at: :desc)
                                .limit(6)
    @top_providers = load_top_providers

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
                           .includes(services: :category, profile_picture_attachment: :blob)
                           .index_by(&:id)
                           .values_at(*recently_active_ids)
                           .compact

    # Backfill if fewer than 8 active — pad with newest providers not in featured
    if @recently_active.length < 8
      need = 8 - @recently_active.length
      have_ids = top_ids + @recently_active.map(&:id)
      filler = User.provider
                   .where.not(id: have_ids)
                   .includes(services: :category, profile_picture_attachment: :blob)
                   .order(created_at: :desc)
                   .limit(need)
      @recently_active += filler.to_a
    end
    decorate_provider_stats(@recently_active)
    @plans = Plan.where(active: true).order(:position)
  end

  private

  def load_top_providers
    rows = Booking.joins(:service)
                  .left_joins(:review)
                  .where(status: :completed)
                  .group("services.provider_id")
                  .select(
                    "services.provider_id AS provider_id",
                    "COUNT(DISTINCT bookings.id) AS completed_bookings_count",
                    "COUNT(reviews.id) AS reviews_count",
                    "COALESCE(AVG(reviews.rating), 0) AS average_rating_value"
                  )
                  .order(Arel.sql("average_rating_value DESC, completed_bookings_count DESC"))
                  .limit(4)

    provider_ids = rows.map { |row| row.provider_id.to_i }
    providers = User.provider
                    .where(id: provider_ids)
                    .includes(services: :category, profile_picture_attachment: :blob)
                    .index_by(&:id)
                    .values_at(*provider_ids)
                    .compact

    stats = rows.index_by { |row| row.provider_id.to_i }.transform_values do |row|
      {
        average_rating: row.average_rating_value.to_f.round(1),
        total_reviews: row.reviews_count.to_i,
        total_completed_bookings: row.completed_bookings_count.to_i
      }
    end

    decorate_provider_stats(providers, stats)
  end

  def decorate_provider_stats(providers, preloaded_stats = nil)
    return providers if providers.blank?

    stats = preloaded_stats || provider_stats_for(providers.map(&:id))
    providers.each do |provider|
      provider_stats = stats.fetch(provider.id, default_provider_stats)
      provider.define_singleton_method(:average_rating) { provider_stats[:average_rating] }
      provider.define_singleton_method(:total_reviews) { provider_stats[:total_reviews] }
      provider.define_singleton_method(:total_completed_bookings) { provider_stats[:total_completed_bookings] }
    end
  end

  def provider_stats_for(provider_ids)
    return {} if provider_ids.blank?

    completed_counts = Booking.joins(:service)
                              .where(services: { provider_id: provider_ids }, status: :completed)
                              .group("services.provider_id")
                              .count

    review_rows = Review.joins(booking: :service)
                        .where(services: { provider_id: provider_ids })
                        .group("services.provider_id")
                        .pluck(
                          "services.provider_id",
                          Arel.sql("COUNT(reviews.id)"),
                          Arel.sql("COALESCE(AVG(reviews.rating), 0)")
                        )

    review_stats = review_rows.index_by { |provider_id, _count, _avg| provider_id.to_i }
    provider_ids.index_with do |provider_id|
      row = review_stats[provider_id.to_i]
      {
        average_rating: row ? row[2].to_f.round(1) : 0,
        total_reviews: row ? row[1].to_i : 0,
        total_completed_bookings: completed_counts[provider_id].to_i
      }
    end
  end

  def default_provider_stats
    { average_rating: 0, total_reviews: 0, total_completed_bookings: 0 }
  end
end
