#!/usr/bin/env bash
# exit on error
set -o errexit

# Build commands for Render deployment
echo "🚀 Starting Render build process..."

echo "📦 Installing Ruby gems..."
bundle install

echo "🎨 Precompiling assets..."
bundle exec rails assets:precompile

echo "🗄️ Running database migrations..."
bundle exec rails db:create db:migrate

echo "🌱 Seeding database (if needed)..."
bundle exec rails db:seed

echo "✅ Build completed successfully!"