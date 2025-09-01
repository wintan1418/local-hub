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
