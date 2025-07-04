Rails.application.configure do
  config.twilio = {
    account_sid: ENV['TWILIO_ACCOUNT_SID'],
    auth_token: ENV['TWILIO_AUTH_TOKEN'],
    phone_number: ENV['TWILIO_PHONE_NUMBER'],
    whatsapp_number: ENV['TWILIO_WHATSAPP_NUMBER']
  }
end

# Initialize Twilio client
if Rails.application.config.twilio[:account_sid].present?
  TWILIO_CLIENT = Twilio::REST::Client.new(
    Rails.application.config.twilio[:account_sid],
    Rails.application.config.twilio[:auth_token]
  )
else
  Rails.logger.warn "Twilio credentials not configured. Set TWILIO_ACCOUNT_SID and TWILIO_AUTH_TOKEN environment variables."
  TWILIO_CLIENT = nil
end