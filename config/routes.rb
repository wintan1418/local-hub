Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Root path
  root "home#index"
  
  # Static pages
  get "about", to: "static_pages#about", as: :about
  
  # Additional home page routes for anchor links
  get "home#services", to: "home#index"
  get "home#how-it-works", to: "home#index"
  get "home#testimonials", to: "home#index"
  
  # Devise routes for user authentication
  devise_for :users
  
  # User dashboard
  get 'dashboard', to: 'dashboard#index', as: :user_dashboard
  
  # Catch-all for 404 errors
  match "*path", to: "errors#not_found", via: :all, constraints: ->(req) { !req.path.start_with?("/rails/") }
  
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  # Defines the root path route ("/")
  # root "posts#index"
end
