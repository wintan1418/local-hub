module Admin
  class DashboardController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_admin!

    def index
      # User stats
      @total_users = User.count
      @total_customers = User.where(user_role: 'customer').count
      @total_providers = User.where(user_role: 'provider').count
      @new_users_this_month = User.where(created_at: Time.current.beginning_of_month..Time.current.end_of_month).count
      
      # Service stats
      @total_services = Service.count
      @total_categories = Category.count
      @new_services_this_month = Service.where(created_at: Time.current.beginning_of_month..Time.current.end_of_month).count
      
      # Booking stats
      @total_bookings = Booking.count
      @pending_bookings = Booking.where(status: 'pending').count
      @confirmed_bookings = Booking.where(status: 'confirmed').count
      @completed_bookings = Booking.where(status: 'completed').count
      @total_revenue = Booking.where(status: ['completed', 'confirmed']).sum(:total_price)
      @this_month_revenue = Booking.where(status: ['completed', 'confirmed'], created_at: Time.current.beginning_of_month..Time.current.end_of_month).sum(:total_price)
      
      # Recent activity
      @recent_users = User.order(created_at: :desc).limit(5)
      @recent_services = Service.includes(:provider, :category).order(created_at: :desc).limit(5)
      @recent_bookings = Booking.includes(:customer, :service).order(created_at: :desc).limit(10)
      
      # Reviews
      @total_reviews = Review.count
      @avg_platform_rating = Review.average(:rating)&.round(1) || 0
    end

    private

    def ensure_admin!
      redirect_to root_path, alert: 'Access denied.' unless current_user&.user_role == 'admin'
    end
  end
end 