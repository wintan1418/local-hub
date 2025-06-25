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
