module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_admin!

    def index
      @users = User.order(created_at: :desc)
      @users = @users.where(user_role: params[:role]) if params[:role].present?
      @users = @users.where("email ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
      @users = @users.page(params[:page]).per(20)

      @total_users = User.count
      @total_customers = User.customer.count
      @total_providers = User.provider.count
      @total_admins = User.admin.count
    end

    def show
      @user = User.find(params[:id])
      @bookings = @user.customer? ? @user.bookings.includes(:service).order(created_at: :desc).limit(10) : Booking.joins(:service).where(services: { provider_id: @user.id }).includes(:service, :customer).order(created_at: :desc).limit(10)
    end

    def toggle_role
      @user = User.find(params[:id])
      new_role = params[:role]
      if %w[customer provider admin].include?(new_role) && @user.id != current_user.id
        @user.update(user_role: new_role)
        redirect_to admin_user_path(@user), notice: "Role updated to #{new_role}."
      else
        redirect_to admin_user_path(@user), alert: "Invalid role change."
      end
    end

    private

    def ensure_admin!
      redirect_to root_path, alert: "Access denied." unless current_user&.admin?
    end
  end
end
