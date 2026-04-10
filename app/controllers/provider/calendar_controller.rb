class Provider::CalendarController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_provider!

  def index
    @month = params[:month] ? Date.parse(params[:month]) : Date.current
    @start_date = @month.beginning_of_month.beginning_of_week(:sunday)
    @end_date = @month.end_of_month.end_of_week(:sunday)

    @bookings = Booking.joins(:service)
      .where(services: { provider_id: current_user.id })
      .where(scheduled_at: @start_date.beginning_of_day..@end_date.end_of_day)
      .where.not(status: :cancelled)
      .includes(service: [], customer: [])
      .order(:scheduled_at)

    @bookings_by_date = @bookings.group_by { |b| b.scheduled_at.to_date }
  end

  private

  def ensure_provider!
    redirect_to root_path, alert: "Access denied." unless current_user&.provider?
  end
end
