# Quick Setup Guide

## 1. Environment Variables Setup

Create a `.env` file in the root directory:

```bash
cp .env.example .env
```

Edit `.env` with your actual credentials:

### For Development (Minimum Required)
```bash
# Database
DATABASE_URL=postgresql://username:password@localhost:5432/localservicehub_development

# Rails
RAILS_ENV=development
RAILS_MASTER_KEY=your_master_key_here

# Stripe (Get from https://dashboard.stripe.com/test/apikeys)
STRIPE_PUBLISHABLE_KEY=pk_test_your_key_here
STRIPE_SECRET_KEY=sk_test_your_key_here

# Twilio (Get from https://console.twilio.com/)
TWILIO_ACCOUNT_SID=your_account_sid_here
TWILIO_AUTH_TOKEN=your_auth_token_here
TWILIO_PHONE_NUMBER=+1234567890

# Redis
REDIS_URL=redis://localhost:6379/0
```

## 2. Database Setup

```bash
rails db:create
rails db:migrate
rails db:seed
```

## 3. Start the Application

```bash
# Terminal 1: Rails server
rails server

# Terminal 2: Background jobs (optional)
bundle exec sidekiq
```

## 4. Access the Application

- **Main App**: http://localhost:3000
- **Admin Dashboard**: http://localhost:3000/admin/dashboard (requires admin user)

## 5. Test User Accounts

After running `rails db:seed`, you can use these test accounts:

- **Customer**: customer@example.com / password123
- **Provider**: provider@example.com / password123  
- **Admin**: admin@example.com / password123

## Troubleshooting

### Stripe Issues
- Make sure you're using test keys from Stripe Dashboard
- Test keys start with `pk_test_` and `sk_test_`

### Twilio Issues
- Verify your Twilio account has credits
- In trial mode, verify recipient phone numbers in Twilio console
- Check logs: `tail -f log/development.log`

### Database Issues
- Ensure PostgreSQL is running
- Check database.yml configuration
- Run `rails db:reset` to start fresh

## Next Steps

1. Set up production environment variables
2. Configure email settings (SMTP)
3. Set up AWS S3 for file uploads
4. Configure webhooks for Stripe payments
5. Set up monitoring and logging 