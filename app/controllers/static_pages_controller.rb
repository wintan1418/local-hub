class StaticPagesController < ApplicationController
  def about
    @page_title = "About Us | Radius"
    @page_description = "Learn more about Radius and our mission to connect you with trusted local service providers."
    @total_providers = User.provider.count
    @total_customers = User.customer.count
    @total_services = Service.count
    @total_bookings = Booking.count
    @total_reviews = Review.count
    @categories_count = Category.count
  end

  def contact
    @page_title = "Contact Us | Radius"
    @page_description = "Get in touch with Radius. We'd love to hear from you."
  end

  def send_contact
    name = params[:name].to_s.strip
    email = params[:email].to_s.strip
    subject = params[:subject].to_s.strip
    message = params[:message].to_s.strip

    if name.blank? || email.blank? || message.blank?
      flash[:alert] = "Please fill in all required fields."
      redirect_to contact_path
      return
    end

    unless email.match?(URI::MailTo::EMAIL_REGEXP)
      flash[:alert] = "Please enter a valid email address."
      redirect_to contact_path
      return
    end

    ContactMailer.contact_message(name, email, subject, message).deliver_later
    flash[:notice] = "Thank you for reaching out! We'll get back to you shortly."
    redirect_to contact_path
  end
end
