class Provider::AnalyticsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_provider!

  def index
    @services = current_user.services
    provider_bookings = Booking.joins(:service).where(services: { provider_id: current_user.id })

    # Overall stats
    @total_revenue = provider_bookings.where(status: :completed).sum(:total_price)
    @total_bookings = provider_bookings.count
    @completed_bookings = provider_bookings.where(status: :completed).count
    @pending_bookings = provider_bookings.where(status: :pending).count
    @avg_rating = current_user.average_rating
    @total_reviews = current_user.total_reviews
    @completion_rate = @total_bookings > 0 ? ((@completed_bookings.to_f / @total_bookings) * 100).round(1) : 0

    # Monthly revenue (last 6 months)
    @monthly_revenue = (0..5).map do |i|
      month = i.months.ago
      revenue = provider_bookings.where(status: :completed)
        .where(scheduled_at: month.beginning_of_month..month.end_of_month)
        .sum(:total_price)
      { month: month.strftime("%b"), revenue: revenue }
    end.reverse

    # Monthly bookings (last 6 months)
    @monthly_bookings = (0..5).map do |i|
      month = i.months.ago
      count = provider_bookings
        .where(created_at: month.beginning_of_month..month.end_of_month)
        .count
      { month: month.strftime("%b"), count: count }
    end.reverse

    # Top services by revenue
    @top_services = current_user.services
      .left_joins(bookings: [])
      .select("services.*, COALESCE(SUM(bookings.total_price), 0) as total_rev, COUNT(bookings.id) as booking_count")
      .where(bookings: { status: :completed }).or(current_user.services.left_joins(bookings: []).where(bookings: { id: nil }))
      .group("services.id")
      .order("total_rev DESC")
      .limit(5)

    # Recent reviews
    @recent_reviews = Review.joins(booking: :service)
      .where(services: { provider_id: current_user.id })
      .includes(booking: [:customer, :service])
      .order(created_at: :desc)
      .limit(5)
  end

  private

  def ensure_provider!
    redirect_to root_path, alert: "Access denied." unless current_user&.provider?
  end
end
