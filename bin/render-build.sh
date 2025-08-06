#!/usr/bin/env bash
# exit on error
set -o errexit

# Build commands for Render deployment
echo "🚀 Starting Render build process..."

echo "📦 Installing Ruby gems..."
bundle install

echo "🎨 Building Tailwind CSS for production..."
RAILS_ENV=production bundle exec rails tailwindcss:build

echo "🎨 Assets ready - Propshaft will serve them automatically"

echo "🗄️ Running database migrations..."
bundle exec rails db:create db:migrate

echo "🌱 Seeding database (if needed)..."
bundle exec rails db:seed

echo "✅ Build completed successfully!"