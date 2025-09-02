# Run this script to create test notifications for development
# Usage: rails runner db/seeds_notifications.rb

puts "🔔 Creating test notifications for development..."

# Get admin users
admin_users = User.where(user_role: 'admin').limit(3)
provider_users = User.where(user_role: 'provider').limit(5)

if admin_users.any?
  admin_users.each do |admin|
    # Create various notification types for admins
    [
      {
        type: 'verification_pending',
        title: 'New Verification Request',
        message: 'John\'s Handyman Services has submitted verification documents for review.',
        user: admin
      },
      {
        type: 'verification_pending', 
        title: 'Urgent Verification Request',
        message: 'Premium Cleaning Co. has been waiting for verification approval for 3 days.',
        user: admin
      },
      {
        type: 'system_announcement',
        title: 'Weekly Platform Report',
        message: 'This week: 25 new signups, 150 bookings completed, $12,500 revenue generated.',
        user: admin
      },
      {
        type: 'booking_created',
        title: 'High-Value Booking',
        message: 'A $2,500 home renovation booking was just created and needs admin attention.',
        user: admin
      }
    ].each do |notification_data|
      Notification.create!(
        user: notification_data[:user],
        notification_type: notification_data[:type],
        title: notification_data[:title],
        message: notification_data[:message],
        created_at: rand(5.days.ago..1.hour.ago)
      )
    end
  end
end

if provider_users.any?
  provider_users.each do |provider|
    # Create notifications for providers
    [
      {
        type: 'verification_approved',
        title: 'Your Account Has Been Verified!',
        message: 'Congratulations! Your service provider account has been successfully verified.',
        user: provider
      },
      {
        type: 'booking_created',
        title: 'New Booking Request',
        message: "You have a new booking request for #{['Deep Cleaning', 'Plumbing Repair', 'Electrical Work'].sample}.",
        user: provider
      },
      {
        type: 'payment_received',
        title: 'Payment Received',
        message: "You received $#{rand(50..500)} for your completed service.",
        user: provider
      }
    ].each do |notification_data|
      Notification.create!(
        user: notification_data[:user],
        notification_type: notification_data[:type],
        title: notification_data[:title],
        message: notification_data[:message],
        created_at: rand(3.days.ago..1.hour.ago)
      )
    end
  end
end

puts "✅ Created #{Notification.count} total notifications"
puts "   📧 Admin notifications: #{Notification.joins(:user).where(users: {user_role: 'admin'}).count}"
puts "   🔧 Provider notifications: #{Notification.joins(:user).where(users: {user_role: 'provider'}).count}"
puts "\nTo test email notifications in development:"
puts "1. Start mailcatcher: mailcatcher"
puts "2. Visit http://localhost:1025 to view emails"
puts "3. Trigger verification approval/rejection in admin dashboard"
puts "4. Check both database notifications and email delivery"