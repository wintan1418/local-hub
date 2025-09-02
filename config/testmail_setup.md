# 📧 Testmail.app Setup Guide for LocalServiceHub

## 🚀 Quick Setup

### 1. Get Your Testmail.app Credentials
Since you've already signed up at https://testmail.app/console/, get these details:

1. **Username**: Your testmail username (usually your email)
2. **API Key**: Found in your dashboard under "API Keys"
3. **Namespace**: Your unique namespace (e.g., `yourname.testmail.app`)

### 2. Configure Environment Variables

Create or update your `.env.development.local` file:

```bash
# Testmail.app configuration
USE_TESTMAIL=true
TESTMAIL_USERNAME=your_testmail_username
TESTMAIL_API_KEY=your_testmail_api_key
TESTMAIL_NAMESPACE=yourname.testmail.app
```

### 3. Restart Your Rails Server
```bash
rails server
```

## 📨 How to Use Testmail.app

### Test Email Addresses
With Testmail.app, you can use any email address in your namespace:

- `admin@yourname.testmail.app`
- `provider@yourname.testmail.app`
- `customer@yourname.testmail.app`
- `anything@yourname.testmail.app`

### Testing Workflow

1. **Send emails** using our rake tasks or manual triggers
2. **Check your inbox** at https://testmail.app/console/
3. **View emails** in real browsers and devices
4. **Test email links** and interactions

## 🧪 Testing Commands

### Test All Email Templates
```bash
# Uses testmail addresses
rails email:test_testmail

# Test notifications
rails email:test_notifications_testmail

# Test specific templates
rails email:test_verification
```

### Manual Testing
```bash
# Test welcome email
rails runner "UserMailer.welcome_email(User.first).deliver_now"

# Test verification approved
rails runner "UserMailer.verification_approved(User.where(user_role: 'provider').first).deliver_now"
```

## 🔍 Debugging

### Check Configuration
```bash
rails runner "puts Rails.application.config.action_mailer.smtp_settings"
```

### Test SMTP Connection
```bash
rails runner "ActionMailer::Base.smtp_settings.inspect"
```

## 📱 Testing Features

### What You Can Test
- ✅ **Real email delivery** to actual inboxes
- ✅ **Mobile responsiveness** on real devices
- ✅ **Email client compatibility** (Gmail, Outlook, etc.)
- ✅ **Link functionality** and redirects
- ✅ **MJML rendering** in real email clients
- ✅ **Spam filtering** behavior

### Advantages Over Mailcatcher
- 📧 **Real email delivery** vs local capture
- 📱 **Mobile testing** on actual devices
- 🌐 **Multiple email clients** supported
- 🔗 **Clickable links** that work
- 🧪 **Spam testing** capabilities

## 🚨 Important Notes

1. **Development Only**: Only use testmail addresses in development
2. **API Limits**: Check your Testmail.app plan limits
3. **Security**: Never commit API keys to git
4. **Production**: Switch to real SMTP for production

## 🔄 Switching Between Methods

### Use Testmail.app
```bash
export USE_TESTMAIL=true
rails server
```

### Use Mailcatcher
```bash
unset USE_TESTMAIL
mailcatcher
rails server
```

## 📊 Next Steps

1. Configure your Testmail credentials
2. Run `rails email:test_testmail`
3. Check your Testmail inbox
4. Test on different devices and email clients
5. Verify all email links work correctly

Happy email testing! 🎉