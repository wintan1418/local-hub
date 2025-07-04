module Provider
  class DashboardController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_provider!

    def index
      @services = current_user.services.includes(:category)
      @bookings = Booking.includes(:service, :customer).where(service: @services).order(scheduled_at: :asc)
      @recent_bookings = @bookings.limit(5)
      @pending_bookings = @bookings.where(status: "pending")
      @confirmed_bookings = @bookings.where(status: "confirmed")
      @completed_bookings = @bookings.where(status: "completed")

      # Dashboard stats
      @total_services = @services.count
      @total_bookings = @bookings.count
      @total_revenue = @completed_bookings.sum(:total_price)
      @pending_count = @pending_bookings.count
      @this_month_bookings = @bookings.where(created_at: Time.current.beginning_of_month..Time.current.end_of_month).count
      @avg_rating = Review.joins(booking: :service).where(services: { provider_id: current_user.id }).average(:rating)&.round(1) || 0
      @total_reviews = Review.joins(booking: :service).where(services: { provider_id: current_user.id }).count
    end

    private

    def ensure_provider!
      redirect_to root_path, alert: "Access denied." unless current_user&.user_role == "provider"
    end
  end
end
