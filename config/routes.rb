AdwordsOnRails::Application.routes.draw do


  devise_for :users, :controllers => { registrations: 'registrations' }
  resources :after_signup, only: [:show, :update]
  
  namespace :ads do
    namespace :google do
      get "campaigns", to: "campaign#index"
      get "campaigns/filter", to: 'campaign#filter'
      get "campaign/:owner_id/:id", to: "campaign#show", as: 'campaign'

      get "account/index"
      get "account/input"
      get "account/select"

      get "login/prompt"
      get "login/callback"
      get "login/logout"

      get "report/index"
      post "report/get"
      
      root "account#index"
    end

    namespace :facebook do
      get 'account/index'
      get 'login/index'
    end

    get "global_dashboard/index"
    root "global_dashboard#index"
  end

  get "home/index"
  root "home#index"
end
