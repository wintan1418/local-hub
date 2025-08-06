require_relative "boot"

require "rails/all"

# Load environment variables from .env file for development
begin
  env_file = File.expand_path('../..', __FILE__) + '/.env'
  if (ENV['RAILS_ENV'] == 'development' || ENV['RAILS_ENV'].nil?) && File.exist?(env_file)
    File.readlines(env_file).each do |line|
      line = line.strip
      next if line.empty? || line.start_with?('#')
      key, value = line.split('=', 2)
      if key && value
        ENV[key.strip] = value.strip.gsub(/^["']|["']$/, '') # Remove quotes
      end
    end
  end
rescue => e
  # Ignore errors in .env loading during development
  puts "Warning: Could not load .env file: #{e.message}" if ENV['RAILS_ENV'] == 'development'
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Localservicehub
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
