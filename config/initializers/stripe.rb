Rails.application.configure do
  config.stripe = {
    publishable_key: ENV["STRIPE_PUBLISHABLE_KEY"] || Rails.application.credentials.dig(:stripe, :publishable_key),
    secret_key: ENV["STRIPE_SECRET_KEY"] || Rails.application.credentials.dig(:stripe, :secret_key)
  }
end

# Only set Stripe API key if it exists
if Rails.application.config.stripe[:secret_key].present?
  Stripe.api_key = Rails.application.config.stripe[:secret_key]
else
  Rails.logger.warn "Stripe credentials not configured. Payment functionality will be disabled."
end
