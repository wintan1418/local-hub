namespace :tailwind do
  desc "Build Tailwind CSS"
  task :build do
    puts "Building Tailwind CSS..."
    system("npm run build:css")
  end

  desc "Watch for changes and rebuild Tailwind CSS"
  task :watch do
    puts "Watching for Tailwind CSS changes..."
    system("npm run watch:css")
  end
end

# Hook into assets:precompile to ensure Tailwind CSS is built
Rake::Task["assets:precompile"].enhance([ "tailwind:build" ])
