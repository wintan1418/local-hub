module Admin
  class CategoriesController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_admin!

    def index
      @categories = Category.order(:name)
      @category = Category.new
    end

    def create
      @category = Category.new(category_params)
      @category.slug = @category.name.parameterize if @category.name.present?
      if @category.save
        redirect_to admin_categories_path, notice: "Category created."
      else
        @categories = Category.order(:name)
        render :index, status: :unprocessable_entity
      end
    end

    def destroy
      @category = Category.find(params[:id])
      if @category.services.any?
        redirect_to admin_categories_path, alert: "Cannot delete — #{@category.services.count} services use this category."
      else
        @category.destroy
        redirect_to admin_categories_path, notice: "Category deleted."
      end
    end

    private

    def category_params
      params.require(:category).permit(:name, :icon)
    end

    def ensure_admin!
      redirect_to root_path, alert: "Access denied." unless current_user&.admin?
    end
  end
end
