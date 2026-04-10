class ServicesController < ApplicationController
  def index
    @categories = Category.order(:name)
    @query = params[:query]
    @category_id = params[:category_id]
    @sort = params[:sort] || "newest"

    @services = Service.includes(:category, provider: { bookings: :review })

    @services = @services.where("title ILIKE ? OR description ILIKE ?", "%#{@query}%", "%#{@query}%") if @query.present?
    @services = @services.where(category_id: @category_id) if @category_id.present?

    @services = case @sort
    when "price_low"
      @services.order(base_price: :asc)
    when "price_high"
      @services.order(base_price: :desc)
    when "top_rated"
      @services.left_joins(provider: { bookings: :review })
               .group("services.id")
               .order(Arel.sql("COALESCE(AVG(reviews.rating), 0) DESC"))
    else
      @services.order(created_at: :desc)
    end

    @services = @services.page(params[:page]).per(12)
  end

  def show
    @service = Service.includes(:category, provider: { bookings: :review }).find(params[:id])
  end
end
