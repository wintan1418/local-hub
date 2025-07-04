# Twilio CRM Setup & Configuration

## Environment Setup

1. **Add to your environment variables** (.env file):
```bash
TWILIO_ACCOUNT_SID=your_account_sid_here
TWILIO_AUTH_TOKEN=your_auth_token_here
TWILIO_PHONE_NUMBER=your_twilio_phone_number_here
```

2. **For WhatsApp (optional)**:
   - Set up a WhatsApp-enabled number in your Twilio console
   - Add: `TWILIO_WHATSAPP_NUMBER=your_whatsapp_number_here`

3. **Copy credentials from .env.example**:
   - Copy `.env.example` to `.env`
   - Replace placeholder values with your actual Twilio credentials

## CRM Features Available

### 1. **SMS Campaigns**
- Access from Provider Dashboard → SMS Campaigns
- Create targeted campaigns for different user segments
- Personalize messages with template variables
- Track delivery and success rates

### 2. **Phone Verification**
- Secure 6-digit code verification
- 10-minute expiration
- 3 attempt limit
- Automatic phone number validation

### 3. **Automated Notifications**
- Booking confirmations
- Appointment reminders
- Chat message notifications
- Service updates

### 4. **User Preferences**
- Customers can opt-in/out of SMS
- Set quiet hours
- Control notification types

## How to Use

### Creating an SMS Campaign:
1. Go to Provider Dashboard
2. Click "SMS Campaigns" 
3. Click "New Campaign"
4. Select target audience
5. Write message with personalization:
   - `{{first_name}}` - Customer's first name
   - `{{full_name}}` - Full name
   - `{{business_name}}` - Your business name
6. Schedule or send immediately

### Example Campaign Message:
```
Hi {{first_name}}! 🏠 

Spring cleaning special from {{business_name}}! 
Get 20% off all services this week only.

Book now: [your-website]
Reply STOP to unsubscribe
```

## Testing SMS Features

1. **Test Phone Verification**:
   - Go to Profile Settings
   - Add/verify phone number
   - Enter 6-digit code received

2. **Test Campaign**:
   - Create campaign targeting "Test Segment"
   - Send to your own phone number first

## Troubleshooting

### SMS Not Sending?
1. Check environment variables are set
2. Verify Twilio account has credits
3. Ensure phone numbers have country code (+1 for US)
4. Check logs: `tail -f log/development.log`

### Common Errors:
- **"Twilio not configured"**: Set environment variables and restart server
- **"Invalid phone number"**: Ensure format is +1XXXXXXXXXX
- **"Unverified number"**: In trial mode, verify recipient numbers in Twilio console

## Costs

Twilio charges per message:
- SMS: ~$0.0075 per message (US)
- WhatsApp: ~$0.005 per message
- Phone verification: Same as SMS rate

Monitor usage in Twilio console to avoid surprises.

## Security Notes

1. **Never commit credentials** to git
2. Keep auth token secret
3. Use environment variables only
4. Enable 2FA on Twilio account
5. Set up usage alerts in Twilio

## Support

- Twilio Console: https://console.twilio.com
- Twilio Docs: https://www.twilio.com/docs
- Platform Support: Contact admin