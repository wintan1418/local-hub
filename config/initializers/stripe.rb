Rails.application.configure do
  # Try to get from credentials first, fallback to environment variables
  stripe_publishable_key = nil
  stripe_secret_key = nil
  
  begin
    stripe_publishable_key = Rails.application.credentials.dig(:stripe, :publishable_key)
    stripe_secret_key = Rails.application.credentials.dig(:stripe, :secret_key)
  rescue => e
    # Credentials not available or invalid, use environment variables
    Rails.logger.warn "Could not access Rails credentials: #{e.message}" if Rails.env.development?
  end
  
  config.stripe = {
    publishable_key: ENV["STRIPE_PUBLISHABLE_KEY"] || stripe_publishable_key,
    secret_key: ENV["STRIPE_SECRET_KEY"] || stripe_secret_key
  }
end

# Only set Stripe API key if it exists
if Rails.application.config.stripe[:secret_key].present?
  Stripe.api_key = Rails.application.config.stripe[:secret_key]
else
  Rails.logger.warn "Stripe credentials not configured. Payment functionality will be disabled."
end
