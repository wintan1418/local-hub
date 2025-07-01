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

      @upcoming_bookings = current_user.bookings.includes(:service).where('scheduled_at >= ?', Time.current).order(:scheduled_at)
    end

    private

    def ensure_customer!
      redirect_to root_path, alert: 'Access denied.' unless current_user&.user_role == 'customer'
    end
  end
end 