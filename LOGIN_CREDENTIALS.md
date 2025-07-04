# LocalServiceHub - Login Credentials

All users have the password: **password123**

## 🔧 Admin Users (5 total)
These users have full admin access to the platform.

| Email | Role | Status |
|-------|------|--------|
| admin1@localservicehub.com | Admin | Verified |
| admin2@localservicehub.com | Admin | Verified |
| admin3@localservicehub.com | Admin | Verified |
| admin4@localservicehub.com | Admin | Verified |
| admin5@localservicehub.com | Admin | Verified |

## 🛠️ Provider Users (40 total)
Service providers with subscriptions and business profiles.

### Free Plan Providers
| Email | Business Name | Location | Verified | Services |
|-------|---------------|----------|----------|----------|
| provider1@example.com | Goodwin's Professionals | Various | Yes | Tutoring |
| provider2@example.com | Dickinson's Professionals | Various | Yes | Cleaning |
| provider7@example.com | Pfannerstill's Services | Various | Yes | Handyman |
| provider11@example.com | Wisozk's Solutions | Various | No | Cleaning |
| provider22@example.com | Ritchie's Experts | Various | Yes | Tutoring |
| provider25@example.com | Lowe's Experts | Various | No | Tutoring |
| provider26@example.com | Mitchell's Professionals | Various | Yes | Moving |
| provider28@example.com | Jacobs's Solutions | Various | No | Mixed |
| provider29@example.com | Schmeler's Experts | Various | Yes | Painting |
| provider31@example.com | Casper's Solutions | Various | No | Personal Training |
| provider32@example.com | Bernhard's Professionals | Various | Yes | Landscaping |
| provider34@example.com | Kiehn's Solutions | Various | No | Landscaping |
| provider39@example.com | Hegmann's Experts | Various | Yes | Pet Care |

### Professional Plan Providers
| Email | Business Name | Location | Verified | Services |
|-------|---------------|----------|----------|----------|
| provider5@example.com | Herman's Solutions | Various | Yes | Pet Care |
| provider9@example.com | Pacocha's Solutions | Various | No | Multiple |
| provider10@example.com | Wehner's Solutions | Various | Yes | Plumbing |
| provider12@example.com | Graham's Professionals | Various | No | Moving |
| provider14@example.com | Grady's Professionals | Various | Yes | Personal Training |
| provider17@example.com | Miller's Professionals | Various | No | Cleaning |
| provider18@example.com | Stamm's Services | Various | Yes | Painting |
| provider19@example.com | Hammes's Professionals | Various | No | Multiple |
| provider21@example.com | Bruen's Professionals | Various | Yes | Multiple |
| provider23@example.com | Franecki's Services | Various | No | Painting |
| provider24@example.com | Blick's Professionals | Various | Yes | Multiple |
| provider27@example.com | Schmitt's Professionals | Various | No | Multiple |
| provider30@example.com | Sauer's Services | Various | Yes | Electrical |
| provider35@example.com | Hahn's Solutions | Various | No | Multiple |
| provider36@example.com | Haag's Solutions | Various | Yes | Multiple |
| provider37@example.com | Hessel's Solutions | Various | No | Multiple |
| provider40@example.com | Mraz's Solutions | Various | Yes | Electrical |

### Business Plan Providers
| Email | Business Name | Location | Verified | Services |
|-------|---------------|----------|----------|----------|
| provider3@example.com | McClure's Solutions | Various | No | Handyman |
| provider4@example.com | Bode's Experts | Various | Yes | Handyman |
| provider6@example.com | Rau's Professionals | Various | No | Handyman |
| provider8@example.com | Towne's Services | Various | Yes | Moving |
| provider13@example.com | Witting's Experts | Various | No | Moving |
| provider15@example.com | Fahey's Professionals | Various | Yes | Electrical |
| provider16@example.com | Kovacek's Solutions | Various | No | Landscaping |
| provider20@example.com | Schuster's Services | Various | Yes | Handyman |
| provider33@example.com | Hiehn's Solutions | Various | No | Landscaping |
| provider38@example.com | Jacobs's Solutions | Various | Yes | Multiple |

## 👥 Customer Users (55 total)
Regular customers who can book services.

| Email Range | Count | Notes |
|-------------|-------|-------|
| customer1@example.com | 1 | First customer |
| customer2@example.com | 1 | Second customer |
| ... | ... | ... |
| customer55@example.com | 1 | Last customer |

*All customers have basic profiles and can book services from providers.*

## 📊 Platform Statistics

- **Total Users**: 100
- **Admin Users**: 5 (all verified)
- **Provider Users**: 40 (34 verified, 75% verification rate)
- **Customer Users**: 55
- **Total Services**: 92 across 10 categories
- **Total Bookings**: 735 (various statuses)
- **Total Reviews**: 285 (ratings 3-5 stars)
- **Service Categories**: 10 (Home Cleaning, Plumbing, Electrical, etc.)

## 🎯 Testing Scenarios

### Admin Testing
- Login as any admin user to access admin dashboard
- Manage users, services, and platform settings

### Provider Testing (Free Plan)
- Login as `provider1@example.com` 
- Can create 1 service only
- Basic profile features
- View subscription management

### Provider Testing (Professional Plan)
- Login as `provider5@example.com`
- Can create up to 10 services
- Advanced profile features
- Portfolio showcase
- Verification documents

### Provider Testing (Business Plan)
- Login as `provider3@example.com`
- Unlimited services
- Premium features
- Featured listings capabilities

### Customer Testing
- Login as `customer1@example.com`
- Browse and book services
- View provider profiles and reviews
- Access customer dashboard

## 🚀 Key Features to Test

1. **Subscription Management**
   - Upgrade/downgrade plans
   - View billing history
   - Cancel subscriptions

2. **Provider Profiles**
   - Complete profile information
   - Upload verification documents
   - Manage portfolio images

3. **Leaderboard**
   - Visit `/leaderboard` to see top providers
   - Filter by ratings, bookings, revenue
   - View individual provider profiles

4. **Service Management**
   - Create new services (subscription dependent)
   - Manage existing services
   - Set availability and pricing

5. **Booking System**
   - Customers can book services
   - Providers can manage bookings
   - Review system after completion

## 🔗 Important URLs

- Homepage: `/`
- Services: `/services`
- Leaderboard: `/leaderboard`
- Admin Dashboard: `/admin/dashboard`
- Provider Dashboard: `/provider/dashboard`
- Customer Dashboard: `/customer/dashboard`
- Sign Up: `/users/sign_up`
- Sign In: `/users/sign_in`

## 💳 Stripe Integration

The platform now includes full Stripe integration:
- **Test Mode**: Using provided test API keys
- **Products Created**: Professional ($29/month) and Business ($99/month) plans
- **Payment Processing**: Secure checkout with Stripe Elements
- **Webhooks**: Automatic subscription status updates
- **Trial Periods**: 14-day free trials for paid plans

### Stripe Test Cards
Use these for testing payments:
- **Success**: 4242 4242 4242 4242
- **Decline**: 4000 0000 0000 0002
- **Requires 3D Secure**: 4000 0025 0000 3155

---

*All data is generated for testing purposes. Use these credentials to explore the full platform functionality.*