# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

require 'faker'

puts "🌱 Starting seed process..."

# IMPORTANT: This seed file is DESTRUCTIVE by default.
# In production with real users, set SEED_WIPE=false to skip the clean step.
# Or set SEED_SKIP_IF_USERS=true to skip seeding if users already exist.

if ENV['SEED_SKIP_IF_USERS'] == 'true' && User.any?
  puts "⚠️  Users already exist — skipping seed (SEED_SKIP_IF_USERS=true)"
  exit 0
end

if Rails.env.production? && ENV['SEED_CONFIRM'] != 'yes'
  puts "⚠️  Running in production. To wipe and reseed, re-run with SEED_CONFIRM=yes"
  puts "   Example: SEED_CONFIRM=yes bundle exec rails db:seed"
  exit 0
end

if ENV['SEED_WIPE'] != 'false'
  # Clean existing data
  puts "🧹 Cleaning existing data..."
  JobRequestQuote.destroy_all if defined?(JobRequestQuote)
  JobRequest.destroy_all if defined?(JobRequest)
  Referral.destroy_all if defined?(Referral)
  Favorite.destroy_all if defined?(Favorite)
  ServicePackage.destroy_all if defined?(ServicePackage)
  Expense.destroy_all if defined?(Expense)
  Invoice.destroy_all if defined?(Invoice)
  QuoteLineItem.destroy_all if defined?(QuoteLineItem)
  Quote.destroy_all if defined?(Quote)
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
end

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

# Create Admin users with specific roles
admin_roles_data = [
  { role: 'super_admin', name: 'Main Admin', email: 'wintan1418@gmail.com' },
  { role: 'verification_admin', name: 'Verification Admin', email: 'verification@radiusapp.com' },
  { role: 'support_admin', name: 'Support Admin', email: 'support@radiusapp.com' },
  { role: 'content_admin', name: 'Content Admin', email: 'content@radiusapp.com' },
  { role: 'super_admin', name: 'System Admin', email: 'admin@radiusapp.com' }
]

admins = admin_roles_data.map do |admin_data|
  user = User.create!(
    email: admin_data[:email],
    password: 'password123',
    user_role: 'admin',
    admin_role: admin_data[:role],
    first_name: admin_data[:name].split(' ').first,
    last_name: admin_data[:name].split(' ').last,
    phone: Faker::Number.number(digits: 10).to_s,
    bio: "#{admin_data[:name]} managing the Radius platform.",
    verified: true,
    verified_at: 1.year.ago,
    confirmed_at: Time.current  # Auto-confirm admin accounts
  )
  puts "  ✅ Created #{admin_data[:name]}: #{user.email} (#{admin_data[:role]}) - Auto-confirmed"
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
    bio: [
      "Licensed and insured professional with over #{rand(5..15)} years of experience. I take pride in delivering quality work on time and within budget.",
      "Dedicated to providing top-notch service to every customer. I believe in transparent pricing, clear communication, and exceptional results.",
      "Family-owned business serving the local community. We treat every home like our own and guarantee satisfaction on every job.",
      "Certified professional committed to excellence. I stay up-to-date with the latest techniques and use only premium materials.",
      "Passionate about what I do and it shows in my work. Over 500 satisfied customers and counting. Available for same-day service.",
      "Experienced professional offering reliable, affordable service. I focus on building long-term relationships through consistent quality.",
      "Award-winning service provider with a 5-star track record. I bring expertise, professionalism, and attention to detail to every project.",
      "Trained and certified with a commitment to safety and quality. I offer free estimates and competitive pricing for all services.",
      "Your trusted local expert for all your needs. I offer flexible scheduling, upfront pricing, and a satisfaction guarantee on every job.",
      "Former contractor turned specialist. I bring construction-grade expertise to residential projects at affordable prices.",
      "Detail-oriented professional who goes above and beyond. My clients consistently recommend me to their friends and family.",
      "Fully bonded and insured with excellent references. I specialize in both residential and commercial projects.",
      "Customer satisfaction is my number one priority. I show up on time, communicate clearly, and deliver results that exceed expectations.",
      "Eco-friendly practices and sustainable solutions. I use green products whenever possible without compromising on quality.",
      "Small business owner who cares about the community. Every job gets my personal attention from start to finish."
    ].sample,
    business_name: "#{last_name}'s #{[ 'Services', 'Solutions', 'Experts', 'Professionals' ].sample}",
    business_license: "LIC-#{Faker::Number.number(digits: 8)}",
    insurance_number: "INS-#{Faker::Number.number(digits: 10)}",
    years_experience: rand(1..20),
    address: Faker::Address.street_address,
    city: location[:city],
    state: location[:state],
    zip_code: location[:zip],
    verified: [ true, true, false, false ].sample, # 50% verified
    verified_at: [ true, true, false, false ].sample ? rand(1..365).days.ago : nil,
    # Some providers have uploaded documents for verification review
    business_license_document: [ true, true, false ].sample,
    insurance_certificate_document: [ true, true, false ].sample,
    professional_certifications_document: [ true, false, false ].sample,
    government_id_document: [ true, false, false ].sample,
    confirmed_at: Time.current  # Auto-confirm seed accounts
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
    phone: Faker::Number.number(digits: 10).to_s,
    confirmed_at: Time.current  # Auto-confirm seed accounts
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

    service_descriptions = {
      'Deep House Cleaning' => "Thorough top-to-bottom cleaning of your entire home, including kitchens, bathrooms, living areas, and bedrooms. We use eco-friendly products and pay special attention to high-touch surfaces, baseboards, and hard-to-reach areas.",
      'Regular Weekly Cleaning' => "Consistent weekly cleaning service to keep your home fresh and tidy. Includes dusting, vacuuming, mopping, bathroom sanitizing, and kitchen cleaning. Customize the checklist to fit your needs.",
      'Move-in/Move-out Cleaning' => "Comprehensive deep clean designed for moving transitions. We ensure every surface sparkles, from inside cabinets and appliances to windows and baseboards. Leave your old place spotless or start fresh in your new home.",
      'Window Cleaning' => "Professional interior and exterior window cleaning for crystal-clear results. We handle screens, tracks, and sills too. Safe methods for any height, including hard-to-reach windows.",
      'Carpet Cleaning' => "Professional carpet cleaning using hot water extraction to remove deep-set dirt, stains, and allergens. Safe for all carpet types. Includes pre-treatment of high-traffic areas and stubborn stains.",
      'Drain Cleaning' => "Fast and effective drain clearing for sinks, showers, and tubs. We use professional-grade equipment to remove clogs and buildup. Preventive maintenance available to keep drains flowing smoothly.",
      'Pipe Repair' => "Expert pipe repair for leaks, bursts, and corrosion. We handle copper, PVC, and galvanized pipes. Emergency service available with quick response times to minimize water damage.",
      'Water Heater Installation' => "Professional installation of tank and tankless water heaters. We handle permits, old unit removal, and ensure proper connections. Energy-efficient options available to reduce your utility bills.",
      'Bathroom Remodeling' => "Complete bathroom renovation from design to finish. We handle plumbing, tiling, fixtures, vanities, and more. Transform your bathroom into a modern, functional space.",
      'Emergency Plumbing' => "24/7 emergency plumbing service for urgent issues. We respond quickly to burst pipes, severe leaks, sewer backups, and other plumbing emergencies. Available nights and weekends.",
      'Outlet Installation' => "Safe and code-compliant electrical outlet installation. We add standard, GFCI, and USB outlets wherever you need them. Includes proper wiring and circuit load assessment.",
      'Light Fixture Installation' => "Professional installation of chandeliers, recessed lighting, pendant lights, and more. We handle all wiring, mounting, and ensure everything is up to code.",
      'Circuit Breaker Repair' => "Diagnosis and repair of tripping breakers, faulty panels, and electrical issues. We upgrade outdated panels and ensure your electrical system is safe and reliable.",
      'Home Rewiring' => "Complete or partial home rewiring for older homes. We bring your electrical system up to modern safety standards. Includes new panels, outlets, and proper grounding.",
      'Smart Home Setup' => "Transform your home with smart lighting, thermostats, security cameras, and automated systems. We handle installation, configuration, and show you how to use everything.",
      'Lawn Mowing' => "Regular lawn mowing service to keep your yard looking its best. Includes edging, trimming, and blowing. Flexible scheduling with consistent, reliable service every time.",
      'Tree Trimming' => "Professional tree trimming and pruning to improve health, appearance, and safety. We handle trees of all sizes and dispose of all debris. Storm damage cleanup available.",
      'Garden Design' => "Custom garden design and installation tailored to your space and style. We select the right plants for your climate and soil, create beautiful layouts, and handle all planting.",
      'Sprinkler Installation' => "Efficient sprinkler system design and installation for lush, healthy lawns. We use water-saving technology and provide seasonal adjustments. Repair service also available.",
      'Seasonal Cleanup' => "Comprehensive yard cleanup for spring or fall. Includes leaf removal, bed preparation, pruning, mulching, and debris hauling. Get your yard ready for the next season.",
      'Local Moving' => "Stress-free local moving service with experienced movers and proper equipment. We handle packing, loading, transport, and unloading. Furniture protection and careful handling guaranteed.",
      'Long Distance Moving' => "Reliable long-distance moving with full-service options. We coordinate logistics, provide packing materials, and ensure your belongings arrive safely. Tracking available throughout.",
      'Packing Services' => "Professional packing service using quality materials to protect your belongings. We organize, wrap, and box everything efficiently. Perfect for busy families or office relocations.",
      'Furniture Assembly' => "Expert assembly of all types of furniture from IKEA, Wayfair, Amazon, and more. We bring the right tools and follow manufacturer instructions precisely. Disassembly also available.",
      'Storage Solutions' => "Organized storage solutions for your home or business. We help declutter, set up shelving systems, and optimize your space. Climate-controlled storage referrals available.",
      'TV Mounting' => "Professional TV mounting on any wall type. We handle cable management, bracket installation, and ensure a clean, secure setup. Compatible with all TV sizes and brands.",
      'Shelving Installation' => "Custom shelving installation for closets, garages, offices, and living spaces. We work with various materials and styles to maximize your storage and display space.",
      'Door Repair' => "Fix sticking, squeaky, or damaged doors. We handle alignment, hardware replacement, weatherstripping, and frame repairs. Interior and exterior doors of all types.",
      'General Repairs' => "All-around handyman service for those small jobs that add up. We fix, patch, install, and maintain everything around your home. No job too small.",
      'Interior Painting' => "Professional interior painting with clean lines and smooth finishes. We handle prep work, priming, and cleanup. Wide selection of colors and finishes to choose from.",
      'Exterior Painting' => "Durable exterior painting that protects and beautifies your home. We pressure wash, scrape, prime, and apply premium weather-resistant paints. Detailed prep for lasting results.",
      'Cabinet Painting' => "Transform your kitchen or bathroom with freshly painted cabinets. We sand, prime, and apply durable finishes for a factory-quality look at a fraction of replacement cost.",
      'Deck Staining' => "Protect and revitalize your deck with professional staining. We clean, sand, and apply quality stain to extend the life of your wood. Multiple color options available.",
      'Wallpaper Removal' => "Efficient wallpaper removal without damaging your walls. We handle all types of wallpaper and adhesive. Wall repair and prep for painting included.",
      'Dog Walking' => "Reliable daily dog walking service tailored to your pet's needs. We provide exercise, socialization, and potty breaks. GPS tracking and photo updates after each walk.",
      'Pet Sitting' => "In-home pet sitting so your furry friends stay comfortable while you're away. We follow your routine, administer medications, and send daily updates with photos.",
      'Pet Grooming' => "Full-service pet grooming including bathing, haircuts, nail trimming, and ear cleaning. We use gentle, pet-safe products. Mobile grooming available at your door.",
      'Pet Training' => "Positive reinforcement training for dogs of all ages and breeds. We work on obedience, behavior issues, and socialization. In-home and group sessions available.",
      'Veterinary Transport' => "Safe and stress-free transport to and from veterinary appointments. We handle pets with care and can stay during the visit. Regular scheduling available.",
      'Math Tutoring' => "Patient and effective math tutoring for all levels, from elementary through calculus. We break down complex concepts and build confidence through practice and understanding.",
      'Science Tutoring' => "Engaging science tutoring covering biology, chemistry, physics, and more. We use hands-on examples and real-world applications to make learning stick.",
      'Language Tutoring' => "Conversational and academic language tutoring in Spanish, French, Mandarin, and more. We focus on speaking, reading, writing, and cultural understanding.",
      'Test Prep' => "Structured test preparation for SAT, ACT, GRE, and other standardized tests. We provide practice materials, test-taking strategies, and score improvement tracking.",
      'College Counseling' => "Guided college application support including essay review, school selection, and interview prep. We help students present their best selves to admissions committees.",
      'Weight Loss Training' => "Personalized fitness programs designed for sustainable weight loss. We combine cardio, strength training, and nutrition guidance tailored to your goals and lifestyle.",
      'Strength Training' => "Build muscle and increase strength with customized training programs. We focus on proper form, progressive overload, and balanced routines for all fitness levels.",
      'Yoga Classes' => "Relaxing and restorative yoga sessions for beginners to advanced practitioners. We offer various styles including Vinyasa, Hatha, and Yin. Private and small group options.",
      'Nutrition Coaching' => "Evidence-based nutrition coaching to fuel your health goals. We create personalized meal plans, provide grocery guides, and offer ongoing support and accountability.",
      'Group Fitness' => "High-energy group fitness classes that are fun and effective. We offer HIIT, boot camp, circuit training, and more. All fitness levels welcome."
    }

    description = service_descriptions[service_name] || "Professional #{service_name.downcase} service delivered by experienced, verified providers. We focus on quality, reliability, and customer satisfaction. Contact us for a free estimate."

    service = Service.create!(
      provider: provider,
      category: category,
      title: service_name,
      description: description,
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

    booking = Booking.new(
      customer: customer,
      service: service,
      scheduled_at: scheduled_date,
      status: status,
      total_price: service.base_price * rand(1..4)
    )
    booking.skip_availability_check = true
    booking.save!

    # Create review for completed bookings
    if booking.status == 'completed' && [ true, true, false ].sample
      Review.create!(
        booking: booking,
        rating: rand(3..5),
        comment: [
          "Excellent service! Highly recommend to anyone looking for quality work.",
          "Very professional and punctual. Great work! Will definitely book again.",
          "Good service overall, fair pricing. Showed up on time and got the job done.",
          "Amazing experience from start to finish! They went above and beyond what I expected.",
          "Did a great job. Would hire again without hesitation. Very thorough.",
          "Professional, efficient, and friendly! Made the whole process easy.",
          "Exceeded my expectations. The attention to detail was impressive.",
          "Very satisfied with the service provided. Clean work and great communication.",
          "Quick response and quality work. Fixed the issue in no time.",
          "Fantastic service at a reasonable price! Best value I've found.",
          "Showed up right on time and finished ahead of schedule. Couldn't be happier!",
          "Really impressed with the quality. They took the time to explain everything and left the area spotless.",
          "Solid work. Not the cheapest option but definitely worth the price for the quality you get.",
          "Great communicator — kept me updated throughout the whole process. The end result looks amazing.",
          "This was my third time using this provider and they're consistently excellent. Highly reliable.",
          "Honest pricing with no hidden fees. Did exactly what they said they would do.",
          "A bit slow to respond initially, but once they arrived, the work was top-notch.",
          "Went the extra mile to make sure everything was perfect. Even cleaned up after themselves!",
          "Would give 10 stars if I could. Transformed my space completely. So grateful I found them on Radius.",
          "Professional setup, fair pricing, and the work speaks for itself. Already recommended to my neighbors."
        ].sample
      )
    end
  end
end

# ============================================================
# NEW FEATURE SEEDS
# ============================================================

# Service packages — add tiers to 40% of services
puts "📦 Creating service packages..."
package_sets = [
  [
    { name: "Basic", description: "Essential service, quick & efficient", price_multiplier: 0.8, sort_order: 1 },
    { name: "Standard", description: "Most popular — great balance of value and quality", price_multiplier: 1.0, sort_order: 2 },
    { name: "Premium", description: "Full-service with white-glove treatment", price_multiplier: 1.5, sort_order: 3 }
  ],
  [
    { name: "Single Visit", description: "One-time service", price_multiplier: 1.0, sort_order: 1 },
    { name: "Monthly Plan", description: "4 visits/month at a discount", price_multiplier: 3.2, sort_order: 2 }
  ]
]

Service.all.sample((Service.count * 0.4).to_i).each do |service|
  set = package_sets.sample
  set.each do |pkg|
    ServicePackage.create!(
      service: service,
      name: pkg[:name],
      description: pkg[:description],
      price: (service.base_price * pkg[:price_multiplier]).round(2),
      sort_order: pkg[:sort_order]
    )
  end
end
puts "  ✅ Created #{ServicePackage.count} packages across #{ServicePackage.unscoped.distinct.pluck(:service_id).count} services"

# Favorites — customers save favorite providers
puts "❤️  Creating favorites..."
customers.sample(30).each do |customer|
  providers.sample(rand(2..6)).each do |provider|
    Favorite.find_or_create_by(customer: customer, provider: provider)
  end
end
puts "  ✅ Created #{Favorite.count} favorites"

# Vacation mode — 5 providers on vacation
puts "🏖️  Setting vacation mode on some providers..."
providers.sample(5).each do |provider|
  provider.update(vacation_until: rand(7..30).days.from_now)
end
puts "  ✅ #{User.provider.where("vacation_until > ?", Time.current).count} providers on vacation"

# Response times — backfill for existing bookings
puts "⚡ Backfilling response times..."
Booking.where(status: [:confirmed, :completed]).find_each do |booking|
  # Simulate response time: 30 min to 48 hours
  booking.update_column(:first_response_at, booking.created_at + rand(30.minutes..48.hours))
end
puts "  ✅ Backfilled #{Booking.where.not(first_response_at: nil).count} response times"

# Urgent bookings — mark 15% as urgent
puts "⚡ Marking urgent bookings..."
Booking.pending.limit((Booking.pending.count * 0.2).to_i).update_all(urgent: true)
puts "  ✅ #{Booking.where(urgent: true).count} urgent bookings"

# Job requests — customers posting open jobs
puts "💼 Creating job requests..."
job_titles = {
  "Home Cleaning" => [
    { title: "Deep clean needed before Airbnb guest", desc: "3-bedroom house needs a thorough cleaning before guests arrive Friday. Kitchen and bathrooms are priority." },
    { title: "Weekly cleaning for 2-bedroom apartment", desc: "Looking for a reliable cleaner for weekly service, preferably Tuesdays." }
  ],
  "Plumbing" => [
    { title: "Kitchen faucet leaking badly", desc: "The faucet under the kitchen sink has been leaking for 2 days. Getting worse. Need someone ASAP." },
    { title: "Install new water heater", desc: "Old water heater finally died. Need replacement installed, gas line." }
  ],
  "Electrical" => [
    { title: "Install ceiling fan in master bedroom", desc: "Purchased a ceiling fan from Home Depot, need it installed. No existing fixture." }
  ],
  "Landscaping" => [
    { title: "Spring yard cleanup", desc: "Need leaves cleared, bushes trimmed, and flower beds mulched." }
  ],
  "Handyman" => [
    { title: "TV mounting + furniture assembly", desc: "Just moved in. Need 65\" TV mounted and IKEA desk/bookshelf assembled." },
    { title: "Fix squeaky door and loose cabinet hinges", desc: "Several minor fixes around the house. Probably a 1-2 hour job." }
  ]
}

job_titles.each do |cat_name, jobs|
  category = created_categories.find { |c| c.name == cat_name }
  next unless category

  jobs.each do |job_data|
    customer = customers.sample
    location = cities.sample
    JobRequest.create!(
      customer: customer,
      category: category,
      title: job_data[:title],
      description: job_data[:desc],
      budget_min: rand(50..150),
      budget_max: rand(200..500),
      needed_by: rand(1..14).days.from_now,
      city: location[:city],
      state: location[:state],
      zip: location[:zip],
      status: [:open, :open, :open, :awarded].sample
    )
  end
end
puts "  ✅ Created #{JobRequest.count} job requests"

# Job request quotes — providers submit quotes
puts "💬 Creating job quotes..."
JobRequest.open.each do |jr|
  relevant_providers = User.provider.joins(:services).where(services: { category_id: jr.category_id }).distinct.limit(rand(2..5))
  relevant_providers.each do |provider|
    price = rand(jr.budget_min.to_f..jr.budget_max.to_f).round
    JobRequestQuote.create!(
      job_request: jr,
      provider: provider,
      price: price,
      message: [
        "I can handle this — #{rand(5..15)} years of experience in this area. Available #{rand(1..3)} days from now.",
        "Happy to help! I typically charge $#{price} for jobs like this. Can bring all materials if needed.",
        "Seen this exact issue many times. Should be quick. Available tomorrow or this weekend.",
        "Quality work, fair pricing, and fully insured. Let me know if you'd like to proceed.",
        "I've done several similar jobs with great reviews. I can come by for a free estimate first if you prefer."
      ].sample,
      status: :pending
    )
  end
end
puts "  ✅ Created #{JobRequestQuote.count} quotes on job requests"

# Referrals — some customers have referred others
puts "🎁 Creating referrals..."
referring_customers = customers.sample(10)
referring_customers.each do |referrer|
  referrer.update(referral_code: "#{referrer.first_name.parameterize}-#{SecureRandom.hex(3).upcase}") if referrer.referral_code.blank?
  rand(1..4).times do
    referee = customers.sample
    next if referee == referrer
    next if Referral.exists?(referrer: referrer, referee: referee)
    Referral.create!(
      referrer: referrer,
      referee: referee,
      status: [:pending, :completed, :rewarded].sample,
      credit_amount: Referral::CREDIT_AMOUNT
    )
  end
  # Credit balance for referrer
  rewarded_count = referrer.referrals_sent.where(status: :rewarded).count
  referrer.update(referral_credit: rewarded_count * Referral::CREDIT_AMOUNT)
end
puts "  ✅ Created #{Referral.count} referrals"

# Ensure all users have referral codes
User.where(referral_code: nil).find_each do |u|
  u.update(referral_code: "#{(u.first_name || 'user').parameterize}-#{SecureRandom.hex(3).upcase}")
end

# Expenses on some completed bookings
puts "💸 Adding expenses to completed bookings..."
Booking.completed.sample(50).each do |booking|
  rand(1..3).times do
    Expense.create!(
      booking: booking,
      description: [
        "Parts from Home Depot", "Fuel for travel", "Cleaning supplies", "Paint and brushes",
        "Rental equipment", "Contractor assistance", "Materials", "Disposal fee"
      ].sample,
      amount: rand(5.0..80.0).round(2),
      category: Expense::CATEGORIES.sample
    )
  end
end
puts "  ✅ Created #{Expense.count} expenses"

# Invoices for completed bookings (auto-generated)
puts "🧾 Generating invoices for completed bookings..."
Booking.completed.left_joins(:invoice).where(invoices: { id: nil }).find_each do |b|
  Invoice.create!(
    booking: b,
    amount: b.total_price,
    status: :issued,
    issued_at: b.updated_at
  )
end
# Mark some as paid
paid_count = Invoice.count / 2
Invoice.issued.limit(paid_count).each { |i| i.update(status: :paid, paid_at: rand(1..60).days.ago) }
puts "  ✅ #{Invoice.count} invoices (#{Invoice.paid.count} paid)"

# Calculate and display some stats
puts "\n📊 Seed Statistics:"
puts "  • Users: #{User.count} (#{User.where(user_role: 'admin').count} admins, #{User.where(user_role: 'provider').count} providers, #{User.where(user_role: 'customer').count} customers)"
puts "  • Plans: #{Plan.count}"
puts "  • Subscriptions: #{Subscription.count}"
puts "  • Categories: #{Category.count}"
puts "  • Services: #{Service.count}"
puts "  • Service Packages: #{ServicePackage.count}"
puts "  • Bookings: #{Booking.count} (#{Booking.where(urgent: true).count} urgent)"
puts "  • Reviews: #{Review.count}"
puts "  • Favorites: #{Favorite.count}"
puts "  • Job Requests: #{JobRequest.count} (#{JobRequestQuote.count} quotes)"
puts "  • Referrals: #{Referral.count}"
puts "  • Invoices: #{Invoice.count} (#{Invoice.paid.count} paid)"
puts "  • Expenses: #{Expense.count}"
puts "  • Verified Providers: #{User.where(user_role: 'provider', verified: true).count}"
puts "  • Providers on Vacation: #{User.provider.where("vacation_until > ?", Time.current).count}"

puts "\n✅ Seeding completed successfully!"
puts "\n📝 Sample login credentials:"
puts "  🔐 ADMIN ACCOUNTS:"
puts "    Super Admin: superadmin@radiusapp.com / password123"
puts "    Verification Admin: verification@radiusapp.com / password123"
puts "    Support Admin: support@radiusapp.com / password123"
puts "    Content Admin: content@radiusapp.com / password123"
puts "    General Admin: admin@radiusapp.com / password123"
puts "  👔 PROVIDER: provider1@example.com / password123"
puts "  👤 CUSTOMER: customer1@example.com / password123"
