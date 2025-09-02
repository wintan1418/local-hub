# LocalServiceHub

A comprehensive local service marketplace platform built with Ruby on Rails.

## Production Test Accounts

For testing the application in production, use these credentials:

### Admin Account
- **Email:** admin.test@localservicehub.com
- **Password:** TestAdmin123!
- **Features:** User management, service approval, analytics, system settings

### Consumer Account
- **Email:** consumer.test@localservicehub.com
- **Password:** TestConsumer123!
- **Features:** Search services, book appointments, leave reviews, chat with providers

### Provider Account
- **Email:** provider.test@localservicehub.com
- **Password:** TestProvider123!
- **Features:** Create services, manage bookings, upload verification documents, view analytics

To create these test users in production, run:
```bash
rails test_users:create
```

To remove test users:
```bash
rails test_users:remove
```

## Features

- **User Management**: Multi-role system (Customer, Provider, Admin)
- **Service Management**: Create, edit, and manage local services
- **Booking System**: Complete booking and scheduling system
- **Payment Integration**: Stripe payment processing
- **SMS/WhatsApp Integration**: Twilio-powered messaging system
- **Real-time Chat**: In-app messaging between customers and providers
- **CRM Features**: SMS campaigns, phone verification, automated notifications
- **Provider Verification**: Document upload and verification system
- **Subscription Management**: Provider subscription plans
- **Admin Dashboard**: Comprehensive admin interface
- **Leaderboard**: Provider ranking and recognition system

## Prerequisites

- Ruby 3.2+
- Rails 8.0+
- PostgreSQL
- Redis
- Node.js (for asset compilation)

## Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/localservicehub.git
   cd localservicehub
   ```

2. **Install dependencies**
   ```bash
   bundle install
   npm install
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` with your actual credentials (see Environment Variables section below).

4. **Set up the database**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

5. **Start the application**
   ```bash
   rails server
   ```

6. **Start background job processor**
   ```bash
   bundle exec sidekiq
   ```

## Environment Variables

Create a `.env` file in the root directory with the following variables:

### Required Variables

```bash
# Database
DATABASE_URL=postgresql://username:password@localhost:5432/localservicehub_development

# Rails
RAILS_ENV=development
RAILS_MASTER_KEY=your_master_key_here

# Stripe Configuration
STRIPE_PUBLISHABLE_KEY=pk_test_your_publishable_key_here
STRIPE_SECRET_KEY=sk_test_your_secret_key_here
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here

# Twilio Configuration
TWILIO_ACCOUNT_SID=your_account_sid_here
TWILIO_AUTH_TOKEN=your_auth_token_here
TWILIO_PHONE_NUMBER=+1234567890
TWILIO_WHATSAPP_NUMBER=+1234567890

# AWS S3 (for file uploads)
AWS_ACCESS_KEY_ID=your_aws_access_key_here
AWS_SECRET_ACCESS_KEY=your_aws_secret_key_here
AWS_REGION=us-east-1
AWS_BUCKET=your_bucket_name_here

# Redis (for background jobs)
REDIS_URL=redis://localhost:6379/0

# Email (SMTP)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your_email@gmail.com
SMTP_PASSWORD=your_app_password_here

# Application
APP_HOST=localhost:3000
APP_NAME=LocalServiceHub
```

### Getting API Keys

#### Stripe
1. Sign up at [stripe.com](https://stripe.com)
2. Get your API keys from the Stripe Dashboard
3. Set up webhooks for payment processing

#### Twilio
1. Sign up at [twilio.com](https://twilio.com)
2. Get your Account SID and Auth Token from the Twilio Console
3. Purchase a phone number for SMS/WhatsApp

#### AWS S3 (Optional)
1. Create an AWS account
2. Create an S3 bucket for file storage
3. Create an IAM user with S3 access

## Development

### Running Tests
```bash
rails test
```

### Code Quality
```bash
bundle exec rubocop
bundle exec brakeman
```

### Database
```bash
# Reset database
rails db:reset

# Run specific migration
rails db:migrate:up VERSION=20250704153059
```

## Deployment

### Production Setup
1. Set all environment variables in production
2. Configure your web server (Nginx/Apache)
3. Set up SSL certificates
4. Configure Redis and PostgreSQL for production
5. Set up monitoring and logging

### Docker (Optional)
```bash
docker-compose up -d
```

## Security

- Never commit API keys or secrets to version control
- Use environment variables for all sensitive data
- Enable 2FA on all third-party accounts
- Regularly update dependencies
- Monitor for security vulnerabilities

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For support, please contact the development team or create an issue in the repository.
