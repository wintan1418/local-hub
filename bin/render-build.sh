#!/usr/bin/env bash
# exit on error
set -o errexit

# Build commands for Render deployment
echo "🚀 Starting Render build process..."

echo "📦 Installing Ruby gems..."
bundle install

echo "🎨 Building Tailwind CSS..."
bundle exec rails tailwindcss:build

echo "🎨 Precompiling assets..."
RAILS_ENV=production bundle exec rails assets:precompile
RAILS_ENV=production bundle exec rails assets:clean

echo "🗄️ Running database migrations..."
bundle exec rails db:create db:migrate

echo "🌱 Seeding database (if needed)..."
bundle exec rails db:seed

echo "✅ Build completed successfully!"