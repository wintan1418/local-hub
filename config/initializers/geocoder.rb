Geocoder.configure(
  lookup: :nominatim,
  timeout: 5,
  units: :mi,
  cache: Rails.cache,
  cache_options: { expiration: 1.day },
  nominatim: {
    host: "nominatim.openstreetmap.org",
    use_https: true
  }
)
