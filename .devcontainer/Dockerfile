# Development Dockerfile for devcontainer
# This extends the base Dockerfile but keeps root user for development

ARG RUBY_VERSION=3.4.3
FROM ruby:$RUBY_VERSION-slim

# Rails app lives here
WORKDIR /rails

# Install base packages including sudo for development
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libjemalloc2 \
    libvips \
    postgresql-client \
    sudo \
    build-essential \
    git \
    libpq-dev \
    libyaml-dev \
    pkg-config \
    ca-certificates \
    gnupg \
    lsb-release && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set development environment
ENV RAILS_ENV=development \
    BUNDLE_PATH="/usr/local/bundle"

# Copy application files
COPY . .

# Install gems
RUN bundle install

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install npm packages if package.json exists
RUN if [ -f package.json ]; then npm install; fi

# Create assets directory
RUN mkdir -p app/assets/builds

# Build Tailwind CSS using npm instead of Rails task to avoid SassC issues
RUN if [ -f package.json ]; then npm run build:css; fi

# Create necessary directories
RUN mkdir -p db log tmp/cache tmp/pids tmp/sockets

# Expose port
EXPOSE 3000

# Default command
CMD ["./bin/rails", "server", "-b", "0.0.0.0"] 