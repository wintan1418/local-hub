module Customer
  class DashboardController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_customer!

    def index
      @categories = Category.order(:name)
      @query = params[:query]
      @category_id = params[:category_id]
      @services = Service.includes(:provider, :category)
      @services = @services.where('title ILIKE ? OR description ILIKE ?', "%#{@query}%", "%#{@query}%") if @query.present?
      @services = @services.where(category_id: @category_id) if @category_id.present?
      @services = @services.order(created_at: :desc).limit(20)

      @bookings = current_user.bookings.includes(:service).order(:scheduled_at)
      @upcoming_bookings = @bookings.where('scheduled_at >= ?', Time.current).limit(5)
      @past_bookings = @bookings.where('scheduled_at < ?', Time.current).limit(5)
      @pending_bookings = @bookings.where(status: 'pending')
      @confirmed_bookings = @bookings.where(status: 'confirmed')
      
      # Customer stats
      @total_bookings = @bookings.count
      @total_spent = @bookings.where(status: ['completed', 'confirmed']).sum(:total_price)
      @pending_count = @pending_bookings.count
      @this_month_bookings = @bookings.where(created_at: Time.current.beginning_of_month..Time.current.end_of_month).count
      @favorite_services = @bookings.joins(:service).group('services.id').count.sort_by(&:last).reverse.first(3)
    end

    private

    def ensure_customer!
      redirect_to root_path, alert: 'Access denied.' unless current_user&.user_role == 'customer'
    end
  end
end 