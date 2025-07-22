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
  get "dashboard", to: "dashboard#index", as: :user_dashboard

  # Onboarding
  get "welcome", to: "onboarding#welcome", as: :onboarding_welcome
  patch "onboarding/update_profile", to: "onboarding#update_profile", as: :onboarding_update_profile

  # Modular dashboards
  get "customer/dashboard", to: "customer/dashboard#index", as: :customer_dashboard
  namespace :provider do
    get "dashboard", to: "dashboard#index", as: :dashboard
    resources :services, only: [ :new, :create, :edit, :update, :destroy ]

    resource :profile, only: [ :show, :edit, :update ] do
      member do
        get :verification
        post :upload_documents
        get :portfolio
        post :upload_portfolio
        delete :destroy_portfolio_image
      end
    end

    resources :subscriptions, only: [ :index, :new, :create ] do
      collection do
        post :cancel
        get :confirm_payment
        get :payment_success
        get :success
      end
    end

    resources :phone_verifications, only: [] do
      collection do
        post :send_code
        post :verify
      end
    end

    resources :crm_campaigns do
      member do
        post :send_campaign
        post :cancel_campaign
      end
    end

    resource :notification_preference, only: [ :show, :edit, :update ]
  end
  namespace :admin do
    get "dashboard", to: "dashboard#index", as: :dashboard
  end

  resources :services, only: [ :index, :show ] do
    resources :bookings, only: [ :create ]
  end
  resources :bookings, only: [ :destroy ]

  # Leaderboard
  resources :leaderboard, only: [ :index, :show ]

  # Conversations/Chat
  resources :conversations, only: [ :index, :show, :create ] do
    member do
      post :create_message
    end
  end

  # Settings
  get "settings", to: "settings#index", as: :settings
  patch "settings/profile", to: "settings#update_profile", as: :settings_profile
  patch "settings/notifications", to: "settings#update_notifications", as: :settings_notifications
  patch "settings/password", to: "settings#update_password", as: :settings_password
  delete "settings/account", to: "settings#delete_account", as: :delete_account

  # Notifications
  resources :notifications, only: [:index, :show, :destroy] do
    member do
      patch :mark_as_read
    end
    collection do
      patch :mark_all_as_read
    end
  end

  # API routes
  namespace :api do
    resources :providers, only: [ :index ]
  end

  # Webhooks
  namespace :webhooks do
    post "stripe", to: "stripe#create"
  end

  # Catch-all for 404 errors (always last)
  match "*path", to: "errors#not_found", via: :all, constraints: ->(req) {
    !req.path.start_with?("/rails/") &&
    !req.path.start_with?("/users/") &&
    !req.path.start_with?("/assets/")
  }

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  # Defines the root path route ("/")
  # root "posts#index"
end
