# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example seed data for LocalServiceHub

puts 'Seeding categories...'
categories = [
  { name: "Plumbing", slug: "plumbing", icon: "fa-pipe" },
  { name: "Electrical", slug: "electrical", icon: "fa-bolt" },
  { name: "Tutoring", slug: "tutoring", icon: "fa-book" },
  { name: "Cleaning", slug: "cleaning", icon: "fa-broom" }
]
categories.each { |cat| Category.find_or_create_by!(cat) }
puts 'Categories seeded.'

puts 'Seeding admin user...'
admin = User.find_or_create_by!(email: "admin@example.com") do |u|
  u.password = "password"
  u.user_role = :admin
end
puts 'Admin user seeded.'

puts 'Seeding provider user...'
provider = User.find_or_create_by!(email: "provider@example.com") do |u|
  u.password = "password"
  u.user_role = :provider
end
puts 'Provider user seeded.'

puts 'Seeding customer user...'
customer = User.find_or_create_by!(email: "customer@example.com") do |u|
  u.password = "password"
  u.user_role = :customer
end
puts 'Customer user seeded.'

puts 'Seeding service...'
service = Service.find_or_create_by!(title: "Basic Plumbing Fix", provider: provider, category: Category.find_by(slug: "plumbing")) do |s|
  s.description = "Fix leaks and minor plumbing issues."
  s.price_type = :fixed
  s.base_price = 75.0
end
puts 'Service seeded.'
