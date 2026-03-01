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
    @top_providers = User.provider
                         .includes(profile_picture_attachment: :blob)
                         .select { |p| p.total_completed_bookings >= 1 }
                         .sort_by { |p| [-p.average_rating, -p.total_completed_bookings] }
                         .first(4)
  end
end
