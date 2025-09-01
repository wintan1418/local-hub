# syntax = docker/dockerfile:1

# This Dockerfile is designed for both development and production use
# It supports proper environment-specific builds for Render deployment

ARG RUBY_VERSION=3.4.3
FROM ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set default environment (can be overridden)
ARG RAILS_ENV=production
ENV RAILS_ENV=$RAILS_ENV \
    BUNDLE_PATH="/usr/local/bundle"

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems and Node.js for Tailwind
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libyaml-dev pkg-config curl && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install --no-install-recommends -y nodejs && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install application gems based on environment
COPY Gemfile Gemfile.lock ./
RUN if [ "$RAILS_ENV" = "production" ]; then \
        bundle config set --local without 'development test'; \
        bundle install; \
    else \
        bundle install; \
    fi && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy package.json and install Node dependencies if present
COPY package*.json ./
RUN if [ -f package.json ]; then npm install; fi

# Copy application code
COPY . .

# Create assets directory and build Tailwind CSS
RUN mkdir -p app/assets/builds

# Build Tailwind CSS - use dummy key for production builds
RUN if [ "$RAILS_ENV" = "production" ]; then \
        SECRET_KEY_BASE=dummy bundle exec rails tailwindcss:build; \
    else \
        bundle exec rails tailwindcss:build; \
    fi

# Precompile assets for production
RUN if [ "$RAILS_ENV" = "production" ]; then \
        SECRET_KEY_BASE=dummy bundle exec rails assets:precompile; \
    fi

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Final stage for app image
FROM base AS final

# Copy built artifacts: gems and application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    mkdir -p db log tmp/cache tmp/pids tmp/sockets && \
    chown -R rails:rails db log tmp public app/assets/builds
USER rails

# Entrypoint prepares the database
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start server (port will be set by environment variables)
EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]