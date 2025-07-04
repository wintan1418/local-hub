# LocalServiceHub - Navigation Links & Features

## Main Navigation

### For All Users (Not Logged In)
- **Home** (`/`) - Main landing page with services overview
- **About** (`/about`) - About the platform
- **Services** (`/services`) - Browse all available services
- **Leaderboard** (`/leaderboard`) - Top-rated providers *(requires login)*
- **Sign In** (`/users/sign_in`) - User authentication
- **Get Started** (`/users/sign_up`) - User registration

### For Customers (Logged In)
- **Dashboard** (`/customer/dashboard`) - Customer overview and bookings
- **Services** (`/services`) - Browse and book services
- **Messages** (`/conversations`) - Chat with providers
- **Leaderboard** (`/leaderboard`) - View top providers with ratings and badges
- **Profile Settings** (`/users/edit`) - Edit account details

### For Providers (Logged In)
- **Dashboard** (`/provider/dashboard`) - Provider overview with stats
- **Add Service** (`/provider/services/new`) - Create new service offerings
- **Profile** (`/provider/profile`) - Manage business profile and verification
- **Subscriptions** (`/provider/subscriptions`) - Manage subscription plans
- **Messages** (`/conversations`) - Chat with customers
- **Leaderboard** (`/leaderboard`) - View provider rankings

### For Admins (Logged In)
- **Admin Dashboard** (`/admin/dashboard`) - Administrative overview
- **Messages** (`/conversations`) - System-wide chat access
- **Leaderboard** (`/leaderboard`) - Provider management view

## Key Features Accessible

### 1. **Real-Time Chat System**
- Access via Messages in user dropdown menu
- Start conversations from:
  - Service pages (Chat with Provider button)
  - Provider profiles in leaderboard (Start Conversation button)
- Features:
  - Real-time messaging with ActionCable
  - Unread message counts
  - Message history
  - Customer ↔ Provider communication only

### 2. **Provider Leaderboard**
- Sort by: Rating, Revenue, Bookings, Recent Activity
- Filter by service categories
- Provider badges (Elite, Professional, Trusted, Active, New)
- Detailed provider profiles with statistics
- Direct contact buttons for customers

### 3. **Subscription System**
- **Free Plan**: Basic listing
- **Professional Plan**: $29/month - Featured listings, priority support
- **Business Plan**: $59/month - Premium features, analytics, unlimited services
- Stripe integration for payment processing
- Trial periods and subscription management

### 4. **Profile & Verification System**
- Business profiles with verification documents
- Portfolio image galleries
- Professional verification badges
- Service area management

### 5. **Service Management**
- Service creation and editing for providers
- Image uploads and galleries
- Pricing and availability management
- Booking system with calendar integration

## How to Access Subscription Page

For providers wanting to upgrade their subscription:

1. **Sign in** as a provider
2. Click your profile dropdown (top right)
3. Select **Dashboard**
4. Look for subscription status or "Upgrade Plan" button
5. Or navigate directly to `/provider/subscriptions`

Alternatively:
- From provider dashboard, subscription status is displayed
- Click "Manage Subscription" or "Upgrade Plan"
- Access billing and plan management

## Quick Access URLs

### Authentication
- Sign In: `/users/sign_in`
- Sign Up: `/users/sign_up`
- Password Reset: `/users/password/new`

### Dashboards
- Customer Dashboard: `/customer/dashboard`
- Provider Dashboard: `/provider/dashboard` 
- Admin Dashboard: `/admin/dashboard`

### Core Features
- Browse Services: `/services`
- Messages/Chat: `/conversations`
- Provider Rankings: `/leaderboard`
- Provider Subscriptions: `/provider/subscriptions`

### Provider Management
- Profile Management: `/provider/profile`
- Add New Service: `/provider/services/new`
- Verification: `/provider/profile/verification`
- Portfolio: `/provider/profile/portfolio`

## Security & Access Control

- **Authentication required** for dashboards, messages, and provider features
- **Role-based access** (Customer, Provider, Admin)
- **Leaderboard protected** - login required to view
- **Chat restricted** to customer ↔ provider communication only
- **Provider features** require active subscription for service creation

## Test Accounts

Refer to `LOGIN_CREDENTIALS.md` for comprehensive test user credentials across all roles and subscription levels.