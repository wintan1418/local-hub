class ServicesController < ApplicationController
  def index
    @categories = Category.order(:name)
    @query = params[:query]
    @category_id = params[:category_id]
    @services = Service.includes(:provider, :category)
    @services = @services.where("title ILIKE ? OR description ILIKE ?", "%#{@query}%", "%#{@query}%") if @query.present?
    @services = @services.where(category_id: @category_id) if @category_id.present?
    @services = @services.order(created_at: :desc).limit(20)
  end

  def show
    @service = Service.includes(:provider, :category).find(params[:id])
  end
end
