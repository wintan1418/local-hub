namespace :geocode do
  desc "Geocode all providers missing coordinates"
  task providers: :environment do
    providers = User.provider.where(latitude: nil).where.not(address: [nil, ""])
    total = providers.count
    puts "Geocoding #{total} providers..."

    providers.find_each.with_index do |provider, i|
      provider.geocode
      provider.save(validate: false)
      puts "  [#{i + 1}/#{total}] #{provider.display_name}: #{provider.latitude}, #{provider.longitude}"
      sleep 1.1 # Nominatim rate limit: 1 req/sec
    end

    puts "Done!"
  end
end
