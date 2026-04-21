require "csv"

class Provider::ExportsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_provider!

  def bookings
    bookings = Booking.joins(:service).where(services: { provider_id: current_user.id })
      .includes(:customer, :service, :invoice)
      .order(created_at: :desc)

    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["Booking ID", "Customer", "Service", "Scheduled At", "Status", "Price", "Tip", "Paid", "Created At"]
      bookings.each do |b|
        csv << [b.id, b.customer.display_name, b.service.title, b.scheduled_at, b.status, b.total_price, b.tip_amount, b.paid? ? "Yes" : "No", b.created_at]
      end
    end

    send_data csv_data, filename: "bookings-#{Date.current.strftime('%Y%m%d')}.csv", type: "text/csv"
  end

  def revenue
    bookings = Booking.joins(:service).where(services: { provider_id: current_user.id }).completed
      .includes(:invoice)
      .order(updated_at: :desc)

    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["Date", "Booking ID", "Service", "Gross", "Platform Fee", "Net Payout", "Tip", "Invoice #"]
      bookings.each do |b|
        gross = b.total_price
        fee = (b.platform_fee_cents || 0) / 100.0
        net = gross - fee
        csv << [b.updated_at.to_date, b.id, b.service.title, gross, fee, net, b.tip_amount, b.invoice&.invoice_number]
      end
    end

    send_data csv_data, filename: "revenue-#{Date.current.strftime('%Y%m%d')}.csv", type: "text/csv"
  end

  private

  def ensure_provider!
    redirect_to root_path, alert: "Access denied." unless current_user&.provider?
  end
end
