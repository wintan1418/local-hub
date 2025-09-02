class EmailConfirmationsController < ApplicationController
  before_action :find_user_by_token, only: [ :show ]

  def show
    if @user&.email_confirmation_token == params[:token]
      @user.confirm_email!
      @user.send_welcome_email

      sign_in(@user) unless user_signed_in?
      redirect_to root_path, notice: 'Your email has been confirmed successfully! Welcome to LocalServiceHub.'
    else
      redirect_to root_path, alert: 'Invalid or expired confirmation link.'
    end
  end

  def create
    if user_signed_in?
      current_user.send_confirmation_email
      render json: { message: 'Confirmation email sent!' }
    else
      render json: { error: 'You must be signed in.' }, status: :unauthorized
    end
  end

  private

  def find_user_by_token
    @user = User.find_by(email_confirmation_token: params[:token]) if params[:token].present?
  end
end
