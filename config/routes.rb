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
      get "account/new"
      get 'account/update_time_zone', as: 'update_time_zone'

      get "login/prompt"
      get "login/callback"
      get "login/logout"

      get "report/index"
      post "report/get"
      post "account/create_account"
      
      root "account#index"
    end

    get "global_dashboard/index"
    root "global_dashboard#index"
  end

  get "home/index"
  root "home#index"
end
