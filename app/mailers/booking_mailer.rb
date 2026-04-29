class BookingMailer < ApplicationMailer
  def review_reminder(booking)
    @booking = booking
    @customer = booking.customer
    @provider = booking.service.provider
    @service = booking.service
    @first_name = @customer.first_name.presence || @customer.display_name.split(" ").first
    @review_url = Rails.application.routes.url_helpers.new_booking_review_url(booking)

    mail(
      to: @customer.email,
      subject: "How was your #{@service.title.downcase} with #{@provider.display_name}?"
    )
  end
end
