namespace :email do
  desc "Test all MJML email templates in development"
  task test_all: :environment do
    puts "🧪 Testing all MJML email templates..."
    
    # Create test users if they don't exist
    admin = User.find_by(email: 'admin@test.com') || User.create!(
      email: 'admin@test.com',
      password: 'password123',
      user_role: 'admin',
      admin_role: 'super_admin',
      first_name: 'Test',
      last_name: 'Admin',
      confirmed_at: Time.current
    )
    
    provider = User.find_by(email: 'provider@test.com') || User.create!(
      email: 'provider@test.com',
      password: 'password123',
      user_role: 'provider',
      first_name: 'Test',
      last_name: 'Provider',
      business_name: 'Test Services Inc.',
      confirmed_at: Time.current
    )
    
    customer = User.find_by(email: 'customer@test.com') || User.create!(
      email: 'customer@test.com',
      password: 'password123',
      user_role: 'customer',
      first_name: 'Test',
      last_name: 'Customer',
      confirmed_at: Time.current
    )
    
    puts "✅ Test users created/found"
    
    # Test welcome email
    puts "📧 Testing welcome email..."
    UserMailer.welcome_email(provider).deliver_now
    
    # Test confirmation email
    puts "📧 Testing confirmation email..."
    provider.update(confirmed_at: nil, confirmation_token: 'test123')
    UserMailer.confirmation_instructions(provider, 'test123').deliver_now
    
    # Test password reset
    puts "📧 Testing password reset email..."
    provider.update(reset_password_token: 'reset123', reset_password_sent_at: Time.current)
    UserMailer.password_reset_instructions(provider, 'reset123').deliver_now
    
    # Test verification emails
    puts "📧 Testing verification approved email..."
    UserMailer.verification_approved(provider).deliver_now
    
    puts "📧 Testing verification rejected email..."
    UserMailer.verification_rejected(provider, "Documents were unclear").deliver_now
    
    puts "📧 Testing verification pending email..."
    UserMailer.verification_pending(provider).deliver_now
    
    # Test booking emails if we have services and bookings
    service = provider.services.first || Service.create!(
      provider: provider,
      category: Category.first || Category.create!(name: 'Test Service', slug: 'test'),
      title: 'Test Service',
      description: 'Test description',
      price_type: 'hourly',
      base_price: 50.00
    )
    
    booking = Booking.create!(
      customer: customer,
      service: service,
      scheduled_at: 1.day.from_now,
      status: 'pending',
      total_price: 100.00
    )
    
    puts "📧 Testing booking confirmation email..."
    UserMailer.booking_confirmation(booking).deliver_now
    
    puts "📧 Testing booking update email..."
    UserMailer.booking_update(booking).deliver_now
    
    puts "📧 Testing new booking notification email..."
    UserMailer.new_booking_notification(booking).deliver_now
    
    puts "\n🎉 All MJML email templates tested!"
    puts "📬 Check your mailcatcher at http://localhost:1025 to view the beautiful responsive emails"
    puts "\nTo start mailcatcher if not running:"
    puts "  gem install mailcatcher"
    puts "  mailcatcher"
    puts "\n💡 MJML templates are automatically compiled to responsive HTML!"
  end
  
  desc "Test notification system with emails"
  task test_notifications: :environment do
    puts "🔔 Testing notification system with email delivery..."
    
    admin = User.where(user_role: 'admin').first
    provider = User.where(user_role: 'provider').first
    
    if admin.nil? || provider.nil?
      puts "❌ Please run rails db:seed first to create test users"
      exit
    end
    
    # Test verification notifications with emails
    puts "📧 Testing verification approved notification + email..."
    Notification.create_verification_notification(provider, :approved)
    
    puts "📧 Testing verification rejected notification + email..."
    Notification.create_verification_notification(provider, :rejected, "Please resubmit clearer documents")
    
    puts "📧 Testing verification pending notification + email..."
    Notification.create_verification_notification(provider, :pending)
    
    puts "\n✅ Notification tests completed!"
    puts "📊 Total notifications: #{Notification.count}"
    puts "📧 Check mailcatcher at http://localhost:1025 for emails"
    puts "🔗 Check notifications at http://localhost:3000/notifications"
  end
  
  desc "Setup development email environment"
  task setup_dev: :environment do
    puts "🚀 Setting up comprehensive email testing environment..."
    
    # Check if mailcatcher is running
    begin
      response = Net::HTTP.get_response(URI('http://localhost:1025'))
      puts "✅ Mailcatcher is running at http://localhost:1025"
    rescue
      puts "❌ Mailcatcher not running. Please start it:"
      puts "  gem install mailcatcher"
      puts "  mailcatcher"
      puts "  Then visit http://localhost:1025"
    end
    
    # Check email configuration
    puts "\n📧 Checking email configuration..."
    config = Rails.application.config.action_mailer
    puts "✅ Delivery method: #{config.delivery_method}"
    puts "✅ Default URL options: #{config.default_url_options}"
    puts "✅ SMTP settings: #{config.smtp_settings}"
    
    # Create test notifications
    Rake::Task["db:seed"].invoke if Notification.count == 0
    puts "✅ Database seeded with test data"
    
    puts "\n🎯 Development email testing ready!"
    puts "\nQuick test commands:"
    puts "  rails email:test_all           # Test all email templates"
    puts "  rails email:test_notifications # Test notification system"
    puts "  rails runner db/seeds_notifications.rb # Add test notifications"
    puts "\nDashboard URLs:"
    puts "  http://localhost:3000/notifications  # View notifications"
    puts "  http://localhost:1025                # View sent emails"
    puts "  http://localhost:3000/admin/dashboard # Admin dashboard"
  end
end