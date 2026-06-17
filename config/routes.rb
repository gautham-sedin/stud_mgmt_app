Rails.application.routes.draw do
  devise_for :users
  root "home#index"

  resources :students

  resources :users, only: [ :index ]
end
