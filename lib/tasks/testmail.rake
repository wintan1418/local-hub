namespace :email do
  desc "Test all email templates with Testmail.app addresses"
  task test_testmail: :environment do
    puts "📧 Testing all MJML email templates with Testmail.app..."
    
    # Check if testmail is configured
    unless ENV['USE_TESTMAIL'] == 'true'
      puts "❌ Testmail not configured. Set USE_TESTMAIL=true and configure credentials."
      puts "💡 See config/testmail_setup.md for setup instructions"
      exit 1
    end
    
    namespace = ENV['TESTMAIL_NAMESPACE'] || 'test.testmail.app'
    
    # Create test users with testmail addresses
    admin = User.find_by(email: "admin@#{namespace}") || User.create!(
      email: "admin@#{namespace}",
      password: 'password123',
      user_role: 'admin',
      admin_role: 'super_admin',
      first_name: 'Test',
      last_name: 'Admin',
      confirmed_at: Time.current
    )
    
    provider = User.find_by(email: "provider@#{namespace}") || User.create!(
      email: "provider@#{namespace}",
      password: 'password123',
      user_role: 'provider',
      first_name: 'Test',
      last_name: 'Provider',
      business_name: 'Test Services Inc.',
      confirmed_at: nil # Will be confirmed via email
    )
    
    customer = User.find_by(email: "customer@#{namespace}") || User.create!(
      email: "customer@#{namespace}",
      password: 'password123',
      user_role: 'customer',
      first_name: 'Test',
      last_name: 'Customer',
      confirmed_at: nil # Will be confirmed via email
    )
    
    puts "✅ Test users created with @#{namespace} addresses"
    puts "   📧 Admin: admin@#{namespace}"
    puts "   🔧 Provider: provider@#{namespace}"
    puts "   👤 Customer: customer@#{namespace}"
    
    puts "\n📤 Sending test emails..."
    
    # Test welcome emails
    puts "📧 Testing welcome email (provider)..."
    UserMailer.welcome_email(provider).deliver_now
    sleep(1)
    
    puts "📧 Testing welcome email (customer)..."
    UserMailer.welcome_email(customer).deliver_now
    sleep(1)
    
    # Test confirmation email
    puts "📧 Testing confirmation email..."
    provider.update(confirmation_token: Devise.friendly_token)
    UserMailer.confirmation_instructions(provider, provider.confirmation_token).deliver_now
    sleep(1)
    
    # Test password reset
    puts "📧 Testing password reset email..."
    provider.update(reset_password_token: Devise.friendly_token, reset_password_sent_at: Time.current)
    UserMailer.password_reset_instructions(provider, provider.reset_password_token).deliver_now
    sleep(1)
    
    # Test verification emails
    puts "📧 Testing verification approved email..."
    UserMailer.verification_approved(provider).deliver_now
    sleep(1)
    
    puts "📧 Testing verification rejected email..."
    UserMailer.verification_rejected(provider, "Documents were not clear enough").deliver_now
    sleep(1)
    
    puts "📧 Testing verification pending email..."
    UserMailer.verification_pending(provider).deliver_now
    sleep(1)
    
    # Create booking for testing
    service = provider.services.first
    unless service
      category = Category.first || Category.create!(name: 'Test Service', slug: 'test')
      service = Service.create!(
        provider: provider,
        category: category,
        title: 'Test Service',
        description: 'Test description',
        price_type: 'hourly',
        base_price: 50.00
      )
    end
    
    booking = Booking.find_or_create_by(
      customer: customer,
      service: service,
      scheduled_at: 1.day.from_now,
      status: 'pending',
      total_price: 100.00
    )
    
    puts "📧 Testing booking confirmation email..."
    UserMailer.booking_confirmation(booking).deliver_now
    sleep(1)
    
    puts "📧 Testing booking update email..."
    UserMailer.booking_update(booking).deliver_now
    sleep(1)
    
    puts "📧 Testing new booking notification email..."
    UserMailer.new_booking_notification(booking).deliver_now
    
    puts "\n🎉 All MJML email templates sent to Testmail.app!"
    puts "📬 Check your emails at: https://testmail.app/console/"
    puts "📱 Test on different devices and email clients"
    puts "🔗 Verify all links work correctly"
    
    puts "\n📊 Email Summary:"
    puts "   📧 Total emails sent: 9"
    puts "   🏠 Namespace: #{namespace}"
    puts "   👥 Test users: 3 (admin, provider, customer)"
    
    puts "\n💡 Pro Tips:"
    puts "   📱 Open emails on mobile devices"
    puts "   🔗 Click all links to test functionality"
    puts "   📧 Try different email clients (Gmail, Outlook, etc.)"
    puts "   🧪 Check spam folders for delivery testing"
  end
  
  desc "Test notification system with Testmail.app"
  task test_notifications_testmail: :environment do
    puts "🔔 Testing notification system with Testmail.app..."
    
    unless ENV['USE_TESTMAIL'] == 'true'
      puts "❌ Testmail not configured. Run: export USE_TESTMAIL=true"
      exit 1
    end
    
    namespace = ENV['TESTMAIL_NAMESPACE'] || 'test.testmail.app'
    
    admin = User.find_by(email: "admin@#{namespace}")
    provider = User.find_by(email: "provider@#{namespace}")
    
    if admin.nil? || provider.nil?
      puts "❌ Test users not found. Run 'rails email:test_testmail' first"
      exit 1
    end
    
    puts "📧 Testing verification notifications with email delivery..."
    
    # Test verification approved
    puts "✅ Testing verification approved..."
    Notification.create_verification_notification(provider, :approved)
    sleep(1)
    
    # Test verification rejected  
    puts "❌ Testing verification rejected..."
    Notification.create_verification_notification(provider, :rejected, "Please provide clearer document photos")
    sleep(1)
    
    # Test verification pending
    puts "⏳ Testing verification pending..."
    Notification.create_verification_notification(provider, :pending)
    
    puts "\n✅ Notification tests completed!"
    puts "📊 Created #{Notification.count} total notifications"
    puts "📧 Sent 3 notification emails to: provider@#{namespace}"
    puts "🔗 Check inbox: https://testmail.app/console/"
    puts "🔔 Check notifications: http://localhost:3000/notifications"
  end
  
  desc "Test specific verification emails"
  task test_verification: :environment do
    puts "🏆 Testing verification email templates..."
    
    unless ENV['USE_TESTMAIL'] == 'true'
      puts "❌ Testmail not configured."
      exit 1
    end
    
    namespace = ENV['TESTMAIL_NAMESPACE'] || 'test.testmail.app'
    
    provider = User.find_by(email: "provider@#{namespace}")
    if provider.nil?
      provider = User.create!(
        email: "verification-test@#{namespace}",
        password: 'password123',
        user_role: 'provider',
        first_name: 'Verification',
        last_name: 'Tester',
        business_name: 'Verification Test Services',
        confirmed_at: Time.current
      )
    end
    
    puts "📧 Sending verification email samples..."
    
    # Approved
    puts "✅ Sending verification approved..."
    UserMailer.verification_approved(provider).deliver_now
    sleep(2)
    
    # Rejected with reason
    puts "❌ Sending verification rejected..."
    UserMailer.verification_rejected(provider, "Please provide higher quality photos of your business license. The current image is too blurry to verify the license number and expiration date.").deliver_now
    sleep(2)
    
    # Pending
    puts "⏳ Sending verification pending..."
    UserMailer.verification_pending(provider).deliver_now
    
    puts "\n🎉 Verification emails sent!"
    puts "📧 Check: https://testmail.app/console/"
    puts "💡 Test the email templates on different devices"
  end
  
  desc "Setup Testmail.app configuration check"
  task check_testmail: :environment do
    puts "🔍 Checking Testmail.app configuration..."
    
    if ENV['USE_TESTMAIL'] == 'true'
      puts "✅ USE_TESTMAIL is enabled"
      
      if ENV['TESTMAIL_USERNAME'].present?
        puts "✅ TESTMAIL_USERNAME is set: #{ENV['TESTMAIL_USERNAME']}"
      else
        puts "❌ TESTMAIL_USERNAME is not set"
      end
      
      if ENV['TESTMAIL_API_KEY'].present?
        puts "✅ TESTMAIL_API_KEY is set: #{'*' * ENV['TESTMAIL_API_KEY'].length}"
      else
        puts "❌ TESTMAIL_API_KEY is not set"
      end
      
      if ENV['TESTMAIL_NAMESPACE'].present?
        puts "✅ TESTMAIL_NAMESPACE is set: #{ENV['TESTMAIL_NAMESPACE']}"
      else
        puts "⚠️  TESTMAIL_NAMESPACE not set, using default: test.testmail.app"
      end
      
      puts "\n📧 Current SMTP settings:"
      smtp_settings = Rails.application.config.action_mailer.smtp_settings
      puts "   Address: #{smtp_settings[:address]}"
      puts "   Port: #{smtp_settings[:port]}"
      puts "   Username: #{smtp_settings[:user_name]}"
      puts "   Domain: #{smtp_settings[:domain]}"
      
    else
      puts "❌ USE_TESTMAIL is not enabled"
      puts "💡 To enable: export USE_TESTMAIL=true"
    end
    
    puts "\n📝 Setup Instructions:"
    puts "1. Create .env.development.local file"
    puts "2. Add your Testmail credentials:"
    puts "   USE_TESTMAIL=true"
    puts "   TESTMAIL_USERNAME=your_username"
    puts "   TESTMAIL_API_KEY=your_api_key"
    puts "   TESTMAIL_NAMESPACE=yourname.testmail.app"
    puts "3. Restart Rails server"
    puts "4. Run: rails email:test_testmail"
  end
end