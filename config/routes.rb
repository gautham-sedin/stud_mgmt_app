Rails.application.routes.draw do
  devise_for :users
  root "home#index"

  resources :students do
    member do
      get :download_report
    end

    member do
      delete :remove_profile_photo
    end

    member do
      delete "documents/:attachment_id",
            action: :remove_document,
            as: :remove_document
    end
  end

  resources :users, only: [ :index ]

  namespace :api do
    namespace :v1 do
      post "auth/login", to: "auth#login"

      resources :teachers, only: [ :index, :show, :create, :update, :destroy ] do
        resources :students, only: [ :index, :create ], module: :teachers
      end

      resources :students, 
                only: [ :index, :show, :create, :update, :destroy ] do

        member do
          post :generate_report
          get :report
        end

        collection do
          post :generate_all_reports
        end
      end
      
    end
  end
end
