AdwordsOnRails::Application.routes.draw do
  devise_for :users, :controllers => { registrations: 'registrations' }
  resources :after_signup, only: [:show, :update]
  
  namespace :ads do
    namespace :google do
      get "campaign/index"

      get "account/index"
      get "account/input"
      get "account/select"

      get "login/prompt"
      get "login/callback"
      get "login/logout"

      get "report/index"
      post "report/get"

      get "dashboard/index"
      root "dashboard#index"
    end
    get "global_dashboard/index"
    root "global_dashboard#index"
  end

  root "home#index"
end
