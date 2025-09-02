# Override Tailwind CSS build to prevent SassC conflicts
# We use PostCSS via npm instead

if Rails.env.production? && ENV['SKIP_TAILWIND_BUILD']
  Rails.application.config.after_initialize do
    Rake::Task.define_task('tailwindcss:build') do
      # No-op - we build CSS via npm instead
    end
  end
end
