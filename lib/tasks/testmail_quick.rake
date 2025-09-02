namespace :email do
  desc "Send quick test email to your testmail address"
  task quick_test: :environment do
    puts "📧 Sending test email to skf79.test@inbox.testmail.app..."
    
    # Create or find test user with your testmail address
    test_user = User.find_by(email: 'skf79.test@inbox.testmail.app') || User.create!(
      email: 'skf79.test@inbox.testmail.app',
      password: 'password123',
      user_role: 'provider',
      first_name: 'Test',
      last_name: 'User',
      business_name: 'Test Services',
      confirmed_at: Time.current
    )
    
    puts "✅ Test user created: #{test_user.email}"
    
    # Send welcome email
    puts "📤 Sending welcome email..."
    begin
      UserMailer.welcome_email(test_user).deliver_now
      puts "✅ Email sent successfully!"
      puts "📬 Check your inbox at: https://testmail.app/console/"
      puts "🔄 If you don't see it, hit refresh on the testmail page"
    rescue => e
      puts "❌ Error sending email: #{e.message}"
      puts "💡 Make sure you've updated your credentials in .env.development.local"
    end
    
    # Send verification approved email too
    puts "📤 Sending verification approved email..."
    begin
      UserMailer.verification_approved(test_user).deliver_now
      puts "✅ Verification email sent!"
    rescue => e
      puts "❌ Error: #{e.message}"
    end
    
    puts "\n📊 Test Summary:"
    puts "   📧 Target: skf79.test@inbox.testmail.app"
    puts "   📬 Check: https://testmail.app/console/"
    puts "   🔄 Refresh the page if needed"
  end
  
  desc "Send test verification email"
  task test_verification_quick: :environment do
    puts "🏆 Sending verification test to your testmail..."
    
    test_user = User.find_by(email: 'skf79.test@inbox.testmail.app')
    if test_user.nil?
      puts "❌ Test user not found. Run 'rails email:quick_test' first"
      exit 1
    end
    
    begin
      UserMailer.verification_approved(test_user).deliver_now
      puts "✅ Verification approved email sent!"
      
      sleep(2)
      
      UserMailer.verification_rejected(test_user, "Test rejection reason - documents need to be clearer").deliver_now
      puts "✅ Verification rejected email sent!"
      
      puts "\n📬 Check your emails at: https://testmail.app/console/"
      puts "📱 Test how they look on mobile too!"
      
    rescue => e
      puts "❌ Error: #{e.message}"
    end
  end
end