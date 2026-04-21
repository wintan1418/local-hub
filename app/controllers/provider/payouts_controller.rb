class Provider::PayoutsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_provider!

  def index
    # Refresh status from Stripe
    StripeService.refresh_connect_status(current_user) if current_user.stripe_connect_id.present?

    bookings = Booking.joins(:service).where(services: { provider_id: current_user.id })
    @total_earned = bookings.completed.sum(:provider_payout_cents) / 100.0
    @total_platform_fee = bookings.completed.sum(:platform_fee_cents) / 100.0
    @pending_payout = bookings.confirmed.sum(:provider_payout_cents) / 100.0
    @recent_bookings = bookings.completed.order(updated_at: :desc).limit(10)
  end

  def connect
    return_url = refresh_payouts_provider_url
    refresh_url = provider_payouts_url
    url = StripeService.connect_onboarding_link(current_user, return_url: return_url, refresh_url: refresh_url)
    if url
      redirect_to url, allow_other_host: true
    else
      redirect_to provider_payouts_path, alert: "Unable to start Stripe Connect. Please try again."
    end
  end

  def refresh
    StripeService.refresh_connect_status(current_user) if current_user.stripe_connect_id.present?
    redirect_to provider_payouts_path, notice: "Account status refreshed."
  end

  private

  def ensure_provider!
    redirect_to root_path, alert: "Access denied." unless current_user&.provider?
  end
end
