# Database connection debugging for production
if Rails.env.production?
  Rails.logger.info "=== Database Configuration Debug ==="
  Rails.logger.info "DATABASE_URL present: #{ENV['DATABASE_URL'].present?}"
  Rails.logger.info "DATABASE_URL preview: #{ENV['DATABASE_URL']&.first(50)}..."
  Rails.logger.info "RAILS_ENV: #{Rails.env}"
  
  # Test database connection
  begin
    ActiveRecord::Base.connection.execute("SELECT 1")
    Rails.logger.info "Database connection successful!"
  rescue => e
    Rails.logger.error "Database connection failed: #{e.message}"
    Rails.logger.error "Full error: #{e.backtrace.join("\n")}"
  end
end 