class TwilioService
  class << self
    def send_verification(user, phone)
      return { success: false, error: 'Twilio not configured' } unless twilio_configured?
      
      verification = PhoneVerification.generate_for(user, phone)
      message = "Your LocalServiceHub verification code is: #{verification.code}. Valid for 10 minutes."
      
      result = send_sms(phone, message, :verification, user)
      
      if result[:success]
        { success: true, verification: verification }
      else
        verification.destroy
        result
      end
    end
    
    def send_booking_confirmation(booking)
      return unless twilio_configured?
      
      customer = booking.customer
      service = booking.service
      provider = service.provider
      
      prefs = NotificationPreference.for_user(customer)
      return unless prefs.can_send_sms? && prefs.booking_reminders?
      
      message = <<~MSG
        Booking confirmed! 
        Service: #{service.title}
        Provider: #{provider.business_name || provider.full_name}
        Date: #{booking.booking_date.strftime('%B %d, %Y')}
        Time: #{booking.booking_time}
        Total: $#{booking.total_price}
      MSG
      
      send_sms(customer.phone, message.strip, :booking_confirmation, customer)
    end
    
    def send_booking_reminder(booking)
      return unless twilio_configured?
      
      customer = booking.customer
      service = booking.service
      
      prefs = NotificationPreference.for_user(customer)
      return unless prefs.can_send_sms? && prefs.booking_reminders?
      
      message = <<~MSG
        Reminder: You have a booking tomorrow!
        Service: #{service.title}
        Time: #{booking.booking_time}
        Location: #{booking.location || 'See booking details'}
      MSG
      
      send_sms(customer.phone, message.strip, :booking_reminder, customer)
    end
    
    def send_chat_notification(conversation, message)
      return unless twilio_configured?
      
      recipient = conversation.other_participant(message.sender)
      prefs = NotificationPreference.for_user(recipient)
      
      return unless prefs.can_send_sms? && recipient.phone.present?
      
      sender_name = message.sender.business_name || message.sender.full_name
      content = "New message from #{sender_name}: #{message.content.truncate(100)}"
      
      send_sms(recipient.phone, content, :chat_notification, recipient)
    end
    
    def send_campaign_message(campaign, recipient)
      return { success: false, error: 'Twilio not configured' } unless twilio_configured?
      
      prefs = NotificationPreference.for_user(recipient)
      message = campaign.personalize_message(recipient)
      
      case campaign.campaign_type.to_sym
      when :sms
        return { success: false, error: 'SMS disabled' } unless prefs.can_send_sms?
        send_sms(recipient.phone, message, :marketing, recipient)
      when :whatsapp
        return { success: false, error: 'WhatsApp disabled' } unless prefs.can_send_whatsapp?
        send_whatsapp(recipient.phone, message, recipient)
      else
        { success: false, error: 'Unsupported campaign type' }
      end
    end
    
    private
    
    def send_sms(phone, message, message_type, user)
      return { success: false, error: 'Phone number required' } if phone.blank?
      
      log = SmsLog.create!(
        user: user,
        phone_number: phone,
        message_type: message_type,
        content: message,
        status: :pending
      )
      
      begin
        message = TWILIO_CLIENT.messages.create(
          from: Rails.application.config.twilio[:phone_number],
          to: format_phone(phone),
          body: message
        )
        
        log.mark_sent!(message.sid)
        { success: true, sid: message.sid }
      rescue Twilio::REST::RestError => e
        log.mark_failed!(e.message)
        { success: false, error: e.message }
      end
    end
    
    def send_whatsapp(phone, message, user)
      return { success: false, error: 'WhatsApp number not configured' } if Rails.application.config.twilio[:whatsapp_number].blank?
      
      begin
        message = TWILIO_CLIENT.messages.create(
          from: "whatsapp:#{Rails.application.config.twilio[:whatsapp_number]}",
          to: "whatsapp:#{format_phone(phone)}",
          body: message
        )
        
        { success: true, sid: message.sid }
      rescue Twilio::REST::RestError => e
        { success: false, error: e.message }
      end
    end
    
    def format_phone(phone)
      # Ensure phone number has country code
      phone = phone.to_s.gsub(/\D/, '')
      phone.start_with?('1') ? "+#{phone}" : "+1#{phone}"
    end
    
    def twilio_configured?
      TWILIO_CLIENT.present?
    end
  end
end