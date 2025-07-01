# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example seed data for LocalServiceHub

# Clear existing data
Booking.destroy_all
Service.destroy_all
Category.destroy_all
User.destroy_all

# Create demo users
customer = User.create!(email: 'customer@example.com', password: 'password', user_role: :customer)
provider1 = User.create!(email: 'provider1@example.com', password: 'password', user_role: :provider)
provider2 = User.create!(email: 'provider2@example.com', password: 'password', user_role: :provider)
admin = User.create!(email: 'admin@example.com', password: 'password', user_role: :admin)

# Create categories
categories = [
  { name: 'Home Cleaning', slug: 'home-cleaning', icon: '🧹' },
  { name: 'Handyman', slug: 'handyman', icon: '🔧' },
  { name: 'Moving & Storage', slug: 'moving-storage', icon: '🚚' },
  { name: 'Beauty & Wellness', slug: 'beauty-wellness', icon: '💇' },
  { name: 'Pet Care', slug: 'pet-care', icon: '🐶' },
  { name: 'Tutoring', slug: 'tutoring', icon: '📚' }
]
categories.each { |cat| Category.create!(cat) }

# Create services for each category
Service.create!([
  {
    provider: provider1,
    category: Category.find_by(slug: 'home-cleaning'),
    title: 'SparklePro Apartment Cleaning',
    description: 'Thorough cleaning for apartments and condos. Eco-friendly products. Satisfaction guaranteed!',
    price_type: :fixed,
    base_price: 120.00
  },
  {
    provider: provider2,
    category: Category.find_by(slug: 'handyman'),
    title: 'QuickFix Handyman Services',
    description: 'Repairs, installations, and odd jobs. Fast, reliable, and affordable.',
    price_type: :hourly,
    base_price: 40.00
  },
  {
    provider: provider1,
    category: Category.find_by(slug: 'moving-storage'),
    title: 'EasyMove - Local Moving Help',
    description: 'Professional movers for apartments, homes, and offices. Packing and unpacking available.',
    price_type: :custom,
    base_price: 200.00
  },
  {
    provider: provider2,
    category: Category.find_by(slug: 'beauty-wellness'),
    title: 'GlowUp Mobile Spa',
    description: 'Facials, massages, and beauty treatments in the comfort of your home.',
    price_type: :fixed,
    base_price: 90.00
  },
  {
    provider: provider1,
    category: Category.find_by(slug: 'pet-care'),
    title: 'HappyPaws Dog Walking',
    description: 'Daily walks, playtime, and pet sitting for your furry friends.',
    price_type: :hourly,
    base_price: 25.00
  },
  {
    provider: provider2,
    category: Category.find_by(slug: 'tutoring'),
    title: 'Math Master Tutoring',
    description: 'Expert math tutoring for all ages. In-person or online sessions available.',
    price_type: :hourly,
    base_price: 35.00
  }
])

puts 'Seeded users, categories, and services!'
