#!/usr/bin/env bash
# exit on error
set -o errexit

# Build commands for Render deployment
echo "🚀 Starting Render build process..."

echo "📦 Installing Ruby gems..."
bundle install

echo "📂 Copying JavaScript files for asset precompilation..."
mkdir -p app/assets/builds/channels
mkdir -p app/assets/builds/controllers
cp app/javascript/channels/*.js app/assets/builds/channels/ 2>/dev/null || echo "No channel files to copy"
cp app/javascript/controllers/*.js app/assets/builds/controllers/ 2>/dev/null || echo "No controller files to copy"

echo "🎨 Building Tailwind CSS..."
bundle exec rails tailwindcss:build

echo "🎨 Precompiling assets..."
bundle exec rails assets:precompile
bundle exec rails assets:clean

echo "🗄️ Running database migrations..."
bundle exec rails db:create db:migrate

echo "🌱 Seeding database (if needed)..."
bundle exec rails db:seed

echo "✅ Build completed successfully!"