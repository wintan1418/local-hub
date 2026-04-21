class Provider::ServicePackagesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_provider!
  before_action :set_service

  def create
    @package = @service.packages.build(package_params)
    if @package.save
      redirect_to edit_provider_service_path(@service), notice: "Package added."
    else
      redirect_to edit_provider_service_path(@service), alert: @package.errors.full_messages.to_sentence
    end
  end

  def destroy
    @package = @service.packages.find(params[:id])
    @package.destroy
    redirect_to edit_provider_service_path(@service), notice: "Package removed."
  end

  private

  def set_service
    @service = current_user.services.find(params[:service_id])
  end

  def package_params
    params.require(:service_package).permit(:name, :description, :price, :sort_order)
  end

  def ensure_provider!
    redirect_to root_path, alert: "Access denied." unless current_user&.provider?
  end
end
