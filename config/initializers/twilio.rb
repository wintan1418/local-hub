Rails.application.configure do
  # Try to get from credentials first, fallback to environment variables
  twilio_account_sid = nil
  twilio_auth_token = nil
  twilio_phone_number = nil
  twilio_whatsapp_number = nil
  
  begin
    twilio_account_sid = Rails.application.credentials.dig(:twilio, :account_sid)
    twilio_auth_token = Rails.application.credentials.dig(:twilio, :auth_token)
    twilio_phone_number = Rails.application.credentials.dig(:twilio, :phone_number)
    twilio_whatsapp_number = Rails.application.credentials.dig(:twilio, :whatsapp_number)
  rescue => e
    # Credentials not available or invalid, use environment variables
    Rails.logger.warn "Could not access Rails credentials: #{e.message}" if Rails.env.development?
  end
  
  config.twilio = {
    account_sid: ENV["TWILIO_ACCOUNT_SID"] || twilio_account_sid,
    auth_token: ENV["TWILIO_AUTH_TOKEN"] || twilio_auth_token,
    phone_number: ENV["TWILIO_PHONE_NUMBER"] || twilio_phone_number,
    whatsapp_number: ENV["TWILIO_WHATSAPP_NUMBER"] || twilio_whatsapp_number
  }
end

# Twilio configuration - use environment variables only
twilio_account_sid = ENV['TWILIO_ACCOUNT_SID']
twilio_auth_token = ENV['TWILIO_AUTH_TOKEN']
twilio_phone_number = ENV['TWILIO_PHONE_NUMBER']
twilio_whatsapp_number = ENV['TWILIO_WHATSAPP_NUMBER']

# Initialize Twilio client if credentials are available
if twilio_account_sid.present? && twilio_auth_token.present?
  TWILIO_CLIENT = Twilio::REST::Client.new(twilio_account_sid, twilio_auth_token)
  
  # Set default phone numbers
  TWILIO_PHONE_NUMBER = twilio_phone_number
  TWILIO_WHATSAPP_NUMBER = twilio_whatsapp_number
  
  Rails.logger.info "Twilio client initialized successfully"
else
  Rails.logger.warn "Twilio credentials not configured. SMS/WhatsApp functionality will be disabled."
end
