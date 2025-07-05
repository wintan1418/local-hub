# Pin npm packages by running ./bin/importmap

# Core Rails
pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"

# Controllers
pin_all_from "app/javascript/controllers", under: "controllers"

# AOS Animation Library
pin "aos", to: "https://unpkg.com/aos@2.3.1/dist/aos.js"

# Font Awesome (if needed)
pin "@fortawesome/fontawesome-free", to: "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/js/all.min.js"

# Flatpickr
pin "flatpickr", to: "https://ga.jspm.io/npm:flatpickr@4.6.13/dist/esm/index.js", preload: true
pin "flatpickr/dist/flatpickr.min.css", to: "https://cdn.jsdelivr.net/npm/flatpickr@4.6.13/dist/flatpickr.min.css"
pin "@rails/actioncable", to: "actioncable.esm.js"
pin_all_from "app/javascript/channels", under: "channels"
pin "consumer", to: "channels/consumer.js"
