class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    @app_name = 'Radius'
    mail(to: @user.email, subject: "Welcome to #{@app_name}!")
  end

  def confirmation_instructions(user, token)
    @user = user
    @token = token
    @confirmation_url = user_confirmation_url(confirmation_token: @token)
    @app_name = 'Radius'
    mail(to: @user.email, subject: 'Confirm your email address')
  end

  def password_reset_instructions(user, token)
    @user = user
    @token = token
    @reset_url = edit_user_password_url(reset_password_token: @token)
    @app_name = 'Radius'
    mail(to: @user.email, subject: 'Reset your password')
  end

  def verification_approved(user)
    @user = user
    @app_name = 'Radius'
    @dashboard_url = provider_dashboard_url
    mail(to: @user.email, subject: 'Your account has been verified!')
  end

  def verification_rejected(user, reason = nil)
    @user = user
    @reason = reason
    @app_name = 'Radius'
    @verification_url = verification_provider_profile_url
    mail(to: @user.email, subject: 'Account verification requires attention')
  end

  def verification_pending(user)
    @user = user
    @app_name = 'Radius'
    mail(to: @user.email, subject: 'Verification documents received')
  end

  def booking_confirmation(booking)
    @booking = booking
    @user = booking.customer
    @provider = booking.service.provider
    @service = booking.service
    @app_name = 'Radius'
    mail(to: @user.email, subject: "Booking Confirmation - #{@service.title}")
  end

  def booking_update(booking)
    @booking = booking
    @user = booking.customer
    @provider = booking.service.provider
    @service = booking.service
    @app_name = 'Radius'
    mail(to: @user.email, subject: "Booking Update - #{@service.title}")
  end

  def new_booking_notification(booking)
    @booking = booking
    @provider = booking.service.provider
    @customer = booking.customer
    @service = booking.service
    @app_name = 'Radius'
    mail(to: @provider.email, subject: "New Booking - #{@service.title}")
  end

  def booking_reminder(booking)
    @booking = booking
    @user = booking.customer
    @service = booking.service
    @provider = @service.provider
    @app_name = 'Radius'
    mail(to: @user.email, subject: "Reminder: #{@service.title} tomorrow")
  end

  def review_request(booking)
    @booking = booking
    @user = booking.customer
    @service = booking.service
    @app_name = 'Radius'
    mail(to: @user.email, subject: "How was your experience with #{@service.provider.display_name}?")
  end

  def invoice_reminder(invoice, days)
    @invoice = invoice
    @booking = invoice.booking
    @user = @booking.customer
    @service = @booking.service
    @days = days
    @app_name = 'Radius'
    mail(to: @user.email, subject: "Payment Reminder: Invoice #{@invoice.invoice_number}")
  end

  def quote_sent(quote)
    @quote = quote
    @user = quote.customer
    @provider = quote.provider
    @service = quote.service
    @app_name = 'Radius'
    mail(to: @user.email, subject: "New Quote from #{@provider.display_name} - #{@quote.title}")
  end

  def new_review_notification(review)
    @review = review
    @booking = review.booking
    @provider = @booking.service.provider
    @customer = @booking.customer
    @service = @booking.service
    @app_name = 'Radius'
    mail(to: @provider.email, subject: "New #{@review.rating}-Star Review - #{@service.title}")
  end
end
