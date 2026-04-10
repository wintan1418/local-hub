module Admin
  class ServicesController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_admin!

    def index
      @services = Service.includes(:provider, :category).order(created_at: :desc)
      @services = @services.where(category_id: params[:category_id]) if params[:category_id].present?
      @services = @services.where("title ILIKE ?", "%#{params[:q]}%") if params[:q].present?
      @services = @services.page(params[:page]).per(20)
    end

    def destroy
      @service = Service.find(params[:id])
      @service.destroy
      redirect_to admin_services_path, notice: "Service removed."
    end

    private

    def ensure_admin!
      redirect_to root_path, alert: "Access denied." unless current_user&.admin?
    end
  end
end
