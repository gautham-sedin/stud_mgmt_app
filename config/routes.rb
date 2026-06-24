Rails.application.routes.draw do
  devise_for :users
  root "home#index"

  resources :students

  resources :users, only: [ :index ]

  namespace :api do
    namespace :v1 do
      post "auth/login", to: "auth#login"

      resources :teachers, only: [ :index, :show, :create, :update, :destroy ] do
        resources :students, only: [ :index, :create ], module: :teachers
      end

      resources :students, only: [ :index, :show, :create, :update, :destroy ]
    end
  end
end