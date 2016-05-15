AdwordsOnRails::Application.routes.draw do
  devise_for :users, :controllers => { registrations: 'registrations' }
  resources :after_signup, only: [:show, :update]
  
  namespace :ads do
    namespace :google do
      get "campaigns", to: "campaign#index"
      get "campaign/:account_id/:campaign_id", to: "campaign#show", as: 'campaign_show'

      get "account/index"
      get "account/input"
      get "account/select"
      get "account/new"
      get "account/update_time_zone", as: 'update_time_zone'
      get "account/link", to: "account#link"

      get "login/prompt"
      get "login/callback"
      get "login/logout"

      get "report/index"
      post "report/get"
      post "account/create_account"
      post "account/create_link_account"
      
      root "account#index"
    end

    get "global_dashboard/index"
    root "global_dashboard#index"
  end

  get "home/index"
  root "home#index"
end
