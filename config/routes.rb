Rails.application.routes.draw do
  # The studio: signing in, and everything behind it.
  get  "sign_in",  to: "sessions#new"
  post "sign_in",  to: "sessions#create"
  delete "sign_out", to: "sessions#destroy"

  get "dashboard", to: "dashboard#show"

  get   "account", to: "accounts#edit", as: :account
  patch "account", to: "accounts#update"

  resources :projects, except: %i[ new edit ]
  resources :works, only: %i[ index create update destroy ]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # The public portfolio.
  root "portfolio#show"
end
