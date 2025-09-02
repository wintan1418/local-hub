class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    @app_name = 'LocalServiceHub'
    mail(to: @user.email, subject: "Welcome to #{@app_name}!")
  end

  def confirmation_instructions(user, token)
    @user = user
    @token = token
    @confirmation_url = confirm_email_url(token: @token)
    @app_name = 'LocalServiceHub'
    mail(to: @user.email, subject: 'Confirm your email address')
  end

  def password_reset_instructions(user, token)
    @user = user
    @token = token
    @reset_url = edit_password_reset_url(token: @token)
    @app_name = 'LocalServiceHub'
    mail(to: @user.email, subject: 'Reset your password')
  end

  def verification_approved(user)
    @user = user
    @app_name = 'LocalServiceHub'
    @dashboard_url = provider_dashboard_url
    mail(to: @user.email, subject: 'Your account has been verified!')
  end

  def verification_rejected(user, reason = nil)
    @user = user
    @reason = reason
    @app_name = 'LocalServiceHub'
    @verification_url = verification_provider_profile_url
    mail(to: @user.email, subject: 'Account verification requires attention')
  end

  def verification_pending(user)
    @user = user
    @app_name = 'LocalServiceHub'
    mail(to: @user.email, subject: 'Verification documents received')
  end

  def booking_confirmation(booking)
    @booking = booking
    @user = booking.customer
    @provider = booking.service.provider
    @service = booking.service
    @app_name = 'LocalServiceHub'
    mail(to: @user.email, subject: "Booking Confirmation - #{@service.title}")
  end

  def booking_update(booking)
    @booking = booking
    @user = booking.customer
    @provider = booking.service.provider
    @service = booking.service
    @app_name = 'LocalServiceHub'
    mail(to: @user.email, subject: "Booking Update - #{@service.title}")
  end

  def new_booking_notification(booking)
    @booking = booking
    @provider = booking.service.provider
    @customer = booking.customer
    @service = booking.service
    @app_name = 'LocalServiceHub'
    mail(to: @provider.email, subject: "New Booking - #{@service.title}")
  end
end
