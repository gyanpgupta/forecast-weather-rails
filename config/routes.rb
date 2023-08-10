require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }
  mount Sidekiq::Web => '/sidekiq'

  get 'forecasts/show'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get 'update_search', to: 'forecasts#update_search'
  # Defines the root path route ("/")
  root "forecasts#show"
  resources :search_histories
end