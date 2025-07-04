module Provider
  class ServicesController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_provider!
    before_action :check_subscription!, only: [ :new, :create ]
    before_action :set_service, only: [ :edit, :update, :destroy ]

    def new
      @service = current_user.services.build
      @categories = Category.order(:name)
    end

    def create
      @service = current_user.services.build(service_params)
      if @service.save
        redirect_to provider_dashboard_path, notice: "Service created successfully!"
      else
        @categories = Category.order(:name)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @categories = Category.order(:name)
    end

    def update
      if @service.update(service_params)
        redirect_to provider_dashboard_path, notice: "Service updated successfully!"
      else
        @categories = Category.order(:name)
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @service.destroy
      redirect_to provider_dashboard_path, notice: "Service deleted."
    end

    private

    def set_service
      @service = current_user.services.find(params[:id])
    end

    def service_params
      params.require(:service).permit(:title, :description, :category_id, :price_type, :base_price, images: [])
    end

    def ensure_provider!
      redirect_to root_path, alert: "Access denied." unless current_user&.user_role == "provider"
    end

    def check_subscription!
      unless current_user.has_active_subscription?
        redirect_to new_provider_subscription_path, alert: "You need an active subscription to create services."
      end
    end
  end
end
