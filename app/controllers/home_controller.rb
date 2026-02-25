class HomeController < ApplicationController
  def index
    @categories = Category.order(:name)
    @total_providers = User.provider.count
    @total_customers = User.customer.count
    @total_services = Service.count
    @total_bookings = Booking.count
    @featured_services = Service.includes(:provider, :category)
                                .order(created_at: :desc)
                                .limit(6)
  end
end
