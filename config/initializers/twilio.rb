Rails.application.configure do
  config.twilio = {
    account_sid: ENV["TWILIO_ACCOUNT_SID"] || Rails.application.credentials.dig(:twilio, :account_sid),
    auth_token: ENV["TWILIO_AUTH_TOKEN"] || Rails.application.credentials.dig(:twilio, :auth_token),
    phone_number: ENV["TWILIO_PHONE_NUMBER"] || Rails.application.credentials.dig(:twilio, :phone_number),
    whatsapp_number: ENV["TWILIO_WHATSAPP_NUMBER"] || Rails.application.credentials.dig(:twilio, :whatsapp_number)
  }
end

# Initialize Twilio client
if Rails.application.config.twilio[:account_sid].present? && Rails.application.config.twilio[:auth_token].present?
  TWILIO_CLIENT = Twilio::REST::Client.new(
    Rails.application.config.twilio[:account_sid],
    Rails.application.config.twilio[:auth_token]
  )
else
  Rails.logger.warn "Twilio credentials not configured. SMS/WhatsApp functionality will be disabled."
  TWILIO_CLIENT = nil
end
