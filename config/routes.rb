Rails.application.routes.draw do
  get "users/index"
  devise_for :users
  root "home#index"

  resources :students

  resources :users, only: [:index]
end
