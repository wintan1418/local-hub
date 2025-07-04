class LeaderboardController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @filter = params[:filter] || 'rating'
    @category_id = params[:category_id]
    
    # Get all providers with completed bookings
    base_scope = User.provider
                    .joins(services: { bookings: :review })
                    .where(bookings: { status: 'completed' })
                    .group('users.id')
                    .having('COUNT(reviews.id) >= 3') # At least 3 reviews
    
    # Filter by category if specified
    if @category_id.present?
      base_scope = base_scope.where(services: { category_id: @category_id })
      @selected_category = Category.find(@category_id)
    end
    
    # Apply sorting based on filter
    case @filter
    when 'rating'
      @providers = base_scope.select('users.*, AVG(reviews.rating) as avg_rating, COUNT(DISTINCT bookings.id) as completed_count')
                            .order('avg_rating DESC, completed_count DESC')
                            .limit(50)
    when 'revenue'
      @providers = base_scope.select('users.*, SUM(bookings.total_price) as total_revenue, COUNT(DISTINCT bookings.id) as completed_count')
                            .order('total_revenue DESC')
                            .limit(50)
    when 'bookings'
      @providers = base_scope.select('users.*, COUNT(DISTINCT bookings.id) as completed_count, AVG(reviews.rating) as avg_rating')
                            .order('completed_count DESC, avg_rating DESC')
                            .limit(50)
    when 'recent'
      @providers = base_scope.select('users.*, MAX(bookings.created_at) as latest_booking, COUNT(DISTINCT bookings.id) as completed_count, AVG(reviews.rating) as avg_rating')
                            .order('latest_booking DESC')
                            .limit(50)
    end
    
    @categories = Category.joins(:services).distinct.order(:name)
  end
  
  def show
    @provider = User.provider.find(params[:id])
    @services = @provider.services.includes(:category, :reviews)
    @recent_reviews = Review.joins(booking: :service)
                           .where(services: { provider_id: @provider.id })
                           .includes(:booking)
                           .order(created_at: :desc)
                           .limit(10)
    @stats = {
      avg_rating: @provider.average_rating,
      total_reviews: @provider.total_reviews,
      completed_bookings: @provider.total_completed_bookings,
      total_revenue: @provider.total_revenue,
      completion_rate: @provider.completion_rate
    }
  end
end