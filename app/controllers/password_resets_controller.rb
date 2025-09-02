class PasswordResetsController < ApplicationController
  before_action :find_user_by_token, only: [ :show, :update ]

  def new
  end

  def create
    @user = User.find_by(email: params[:email])

    if @user
      @user.send_password_reset_email
      redirect_to new_user_session_path, notice: 'Password reset instructions have been sent to your email.'
    else
      flash.now[:alert] = 'Email address not found.'
      render :new, status: :unprocessable_entity
    end
  end

  def show
    if @user && !@user.password_reset_expired?
      # Show password reset form
    else
      redirect_to new_password_reset_path, alert: 'Password reset link is invalid or has expired.'
    end
  end

  def update
    if @user && !@user.password_reset_expired?
      if params[:password].present? && params[:password] == params[:password_confirmation]
        @user.reset_password!(params[:password])
        sign_in(@user)
        redirect_to root_path, notice: 'Your password has been reset successfully!'
      else
        @user.errors.add(:password, 'Password and confirmation must match and cannot be blank')
        render :show, status: :unprocessable_entity
      end
    else
      redirect_to new_password_reset_path, alert: 'Password reset link is invalid or has expired.'
    end
  end

  private

  def find_user_by_token
    @user = User.find_by(reset_password_token: params[:token]) if params[:token].present?
  end
end
