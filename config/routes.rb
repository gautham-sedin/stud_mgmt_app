Rails.application.routes.draw do
  devise_for :users
  root "home#index"

  resources :students

  resources :users, only: [ :index ]

  scope :api, defaults: { format: JSON } do
    resources :teachers, only: [:index, :show, :create, :update, :destroy] do
      resources :students, only: [:index, :create], controller: 'api/teacher_students'
    end
    resources :students, only: [:index, :show, :create, :update, :destroy]
  end
end
