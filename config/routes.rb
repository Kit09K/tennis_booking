Rails.application.routes.draw do
  namespace :admin do
    resources :topups, only: [:index, :update]
    resources :adjustcords, only: [:create, :destroy]
  end
  resources :topups, only: [:new, :create]
  resources :bookings, only: [:index, :create, :destroy]
  get "cords/Cords"
  get "cords/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/failure', to: 'sessions#failure'

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  root "cords#index"
  get '/auth/:provider/callback', to: 'sessions#create'
  post '/auth/:provider/callback', to: 'sessions#create'
  
  get '/auth/failure', to: 'sessions#failure'
  
  delete '/logout', to: 'sessions#destroy', as: :logout
  get '/logout', to: 'sessions#destroy'
end
