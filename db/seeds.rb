# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

require 'faker'

puts "🌱 Starting seed process..."

# Clean existing data
puts "🧹 Cleaning existing data..."
Review.destroy_all
Booking.destroy_all
ServiceArea.destroy_all
Availability.destroy_all
Service.destroy_all
Subscription.destroy_all
Plan.destroy_all
Category.destroy_all
User.destroy_all

# Reset primary key sequences
ActiveRecord::Base.connection.reset_pk_sequence!('users')
ActiveRecord::Base.connection.reset_pk_sequence!('categories')
ActiveRecord::Base.connection.reset_pk_sequence!('services')
ActiveRecord::Base.connection.reset_pk_sequence!('bookings')
ActiveRecord::Base.connection.reset_pk_sequence!('reviews')
ActiveRecord::Base.connection.reset_pk_sequence!('plans')
ActiveRecord::Base.connection.reset_pk_sequence!('subscriptions')

# Create Plans
puts "💳 Creating subscription plans..."
plans = [
  {
    name: 'Free',
    price: 0,
    position: 1,
    features: [
      'List up to 1 service',
      'Basic profile page',
      'Accept bookings',
      'Email support'
    ]
  },
  {
    name: 'Professional',
    price: 29,
    position: 2,
    features: [
      'List up to 10 services',
      'Advanced profile customization',
      'Portfolio showcase',
      'Verified provider badge',
      'Priority support',
      'Analytics dashboard'
    ]
  },
  {
    name: 'Business',
    price: 99,
    position: 3,
    features: [
      'Unlimited services',
      'Premium profile features',
      'Featured listings',
      'Advanced analytics',
      'API access',
      'Dedicated support'
    ]
  }
]

created_plans = plans.map do |plan_data|
  Plan.create!(plan_data)
end

# Create Categories
puts "📂 Creating categories..."
categories = [
  { name: 'Home Cleaning', slug: 'home-cleaning', icon: 'fas fa-broom' },
  { name: 'Plumbing', slug: 'plumbing', icon: 'fas fa-wrench' },
  { name: 'Electrical', slug: 'electrical', icon: 'fas fa-bolt' },
  { name: 'Landscaping', slug: 'landscaping', icon: 'fas fa-leaf' },
  { name: 'Moving', slug: 'moving', icon: 'fas fa-truck' },
  { name: 'Handyman', slug: 'handyman', icon: 'fas fa-hammer' },
  { name: 'Painting', slug: 'painting', icon: 'fas fa-paint-roller' },
  { name: 'Pet Care', slug: 'pet-care', icon: 'fas fa-paw' },
  { name: 'Tutoring', slug: 'tutoring', icon: 'fas fa-graduation-cap' },
  { name: 'Personal Training', slug: 'personal-training', icon: 'fas fa-dumbbell' }
]

created_categories = categories.map do |cat|
  Category.create!(cat)
end

# Cities for more realistic data
cities = [
  { city: 'New York', state: 'NY', zip: '10001' },
  { city: 'Los Angeles', state: 'CA', zip: '90001' },
  { city: 'Chicago', state: 'IL', zip: '60601' },
  { city: 'Houston', state: 'TX', zip: '77001' },
  { city: 'Phoenix', state: 'AZ', zip: '85001' },
  { city: 'Philadelphia', state: 'PA', zip: '19101' },
  { city: 'San Antonio', state: 'TX', zip: '78201' },
  { city: 'San Diego', state: 'CA', zip: '92101' },
  { city: 'Dallas', state: 'TX', zip: '75201' },
  { city: 'Miami', state: 'FL', zip: '33101' }
]

# Create Users
puts "👥 Creating users..."

# Create Admin users (5)
admins = 5.times.map do |i|
  user = User.create!(
    email: "admin#{i+1}@localservicehub.com",
    password: 'password123',
    user_role: 'admin',
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    phone: Faker::Number.number(digits: 10).to_s,
    bio: "Experienced admin managing the LocalServiceHub platform.",
    verified: true,
    verified_at: 1.year.ago
  )
  puts "  ✅ Created admin: #{user.email}"
  user
end

# Create Provider users (40)
providers = 40.times.map do |i|
  location = cities.sample
  first_name = Faker::Name.first_name
  last_name = Faker::Name.last_name

  user = User.create!(
    email: "provider#{i+1}@example.com",
    password: 'password123',
    user_role: 'provider',
    first_name: first_name,
    last_name: last_name,
    phone: Faker::Number.number(digits: 10).to_s,
    bio: Faker::Lorem.paragraph(sentence_count: 3),
    business_name: "#{last_name}'s #{[ 'Services', 'Solutions', 'Experts', 'Professionals' ].sample}",
    business_license: "LIC-#{Faker::Number.number(digits: 8)}",
    insurance_number: "INS-#{Faker::Number.number(digits: 10)}",
    years_experience: rand(1..20),
    address: Faker::Address.street_address,
    city: location[:city],
    state: location[:state],
    zip_code: location[:zip],
    verified: [ true, true, true, false ].sample, # 75% verified
    verified_at: [ true, true, true, false ].sample ? rand(1..365).days.ago : nil
  )

  # Create subscription for provider
  plan = created_plans.sample
  Subscription.create!(
    user: user,
    plan: plan,
    status: plan.price == 0 ? :active : [ :active, :trialing ].sample,
    current_period_start: 30.days.ago,
    current_period_end: plan.price == 0 ? 100.years.from_now : 30.days.from_now
  )

  puts "  ✅ Created provider: #{user.email} with #{plan.name} plan"
  user
end

# Create Customer users (55)
customers = 55.times.map do |i|
  user = User.create!(
    email: "customer#{i+1}@example.com",
    password: 'password123',
    user_role: 'customer',
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    phone: Faker::Number.number(digits: 10).to_s
  )
  puts "  ✅ Created customer: #{user.email}"
  user
end

# Create Services for Providers
puts "🛠️  Creating services..."
service_names = {
  'Home Cleaning' => [ 'Deep House Cleaning', 'Regular Weekly Cleaning', 'Move-in/Move-out Cleaning', 'Window Cleaning', 'Carpet Cleaning' ],
  'Plumbing' => [ 'Drain Cleaning', 'Pipe Repair', 'Water Heater Installation', 'Bathroom Remodeling', 'Emergency Plumbing' ],
  'Electrical' => [ 'Outlet Installation', 'Light Fixture Installation', 'Circuit Breaker Repair', 'Home Rewiring', 'Smart Home Setup' ],
  'Landscaping' => [ 'Lawn Mowing', 'Tree Trimming', 'Garden Design', 'Sprinkler Installation', 'Seasonal Cleanup' ],
  'Moving' => [ 'Local Moving', 'Long Distance Moving', 'Packing Services', 'Furniture Assembly', 'Storage Solutions' ],
  'Handyman' => [ 'Furniture Assembly', 'TV Mounting', 'Shelving Installation', 'Door Repair', 'General Repairs' ],
  'Painting' => [ 'Interior Painting', 'Exterior Painting', 'Cabinet Painting', 'Deck Staining', 'Wallpaper Removal' ],
  'Pet Care' => [ 'Dog Walking', 'Pet Sitting', 'Pet Grooming', 'Pet Training', 'Veterinary Transport' ],
  'Tutoring' => [ 'Math Tutoring', 'Science Tutoring', 'Language Tutoring', 'Test Prep', 'College Counseling' ],
  'Personal Training' => [ 'Weight Loss Training', 'Strength Training', 'Yoga Classes', 'Nutrition Coaching', 'Group Fitness' ]
}

providers.each do |provider|
  # Each provider gets 1-5 services
  num_services = provider.subscription.plan.name == 'Free' ? 1 : rand(1..5)
  categories_to_use = created_categories.sample(rand(1..2))

  num_services.times do
    category = categories_to_use.sample
    service_name = service_names[category.name].sample

    service = Service.create!(
      provider: provider,
      category: category,
      title: service_name,
      description: Faker::Lorem.paragraph(sentence_count: 5),
      price_type: [ 'hourly', 'fixed', 'custom' ].sample,
      base_price: rand(25..500)
    )

    # Create availabilities
    5.times do |day|
      Availability.create!(
        service: service,
        day_of_week: day,
        start_time: "09:00",
        end_time: "17:00"
      )
    end

    # Create service areas
    ServiceArea.create!(
      service: service,
      city: provider.city,
      state: provider.state,
      zip: provider.zip_code,
      radius: rand(5..50)
    )

    puts "  ✅ Created service: #{service.title} for #{provider.business_name}"
  end
end

# Create Bookings and Reviews
puts "📅 Creating bookings and reviews..."
Service.all.each do |service|
  # Each service gets 0-15 bookings
  rand(0..15).times do
    customer = customers.sample
    scheduled_date = rand(90.days.ago..30.days.from_now)
    status = if scheduled_date < Time.current
               [ 'completed', 'completed', 'completed', 'cancelled' ].sample
    else
               [ 'pending', 'confirmed' ].sample
    end

    booking = Booking.create!(
      customer: customer,
      service: service,
      scheduled_at: scheduled_date,
      status: status,
      total_price: service.base_price * rand(1..4)
    )

    # Create review for completed bookings
    if booking.status == 'completed' && [ true, true, false ].sample
      Review.create!(
        booking: booking,
        rating: rand(3..5),
        comment: [
          "Excellent service! Highly recommend.",
          "Very professional and punctual. Great work!",
          "Good service, fair pricing.",
          "Amazing experience from start to finish!",
          "Did a great job. Would hire again.",
          "Professional, efficient, and friendly!",
          "Exceeded my expectations. Five stars!",
          "Very satisfied with the service provided.",
          "Quick response and quality work.",
          "Fantastic service at a reasonable price!"
        ].sample
      )
    end
  end
end

# Calculate and display some stats
puts "\n📊 Seed Statistics:"
puts "  • Users: #{User.count} (#{User.where(user_role: 'admin').count} admins, #{User.where(user_role: 'provider').count} providers, #{User.where(user_role: 'customer').count} customers)"
puts "  • Plans: #{Plan.count}"
puts "  • Subscriptions: #{Subscription.count}"
puts "  • Categories: #{Category.count}"
puts "  • Services: #{Service.count}"
puts "  • Bookings: #{Booking.count}"
puts "  • Reviews: #{Review.count}"
puts "  • Verified Providers: #{User.where(user_role: 'provider', verified: true).count}"

puts "\n✅ Seeding completed successfully!"
puts "\n📝 Sample login credentials:"
puts "  Admin: admin1@localservicehub.com / password123"
puts "  Provider: provider1@example.com / password123"
puts "  Customer: customer1@example.com / password123"
