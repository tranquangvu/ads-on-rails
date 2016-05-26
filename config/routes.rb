AdwordsOnRails::Application.routes.draw do
  devise_for :users, :controllers => { registrations: 'registrations' }
  resources :after_signup, only: [:show, :update]
  
  namespace :ads do
    namespace :google do
      # google campaign paths
      get 'campaigns', to: 'campaign#index'
      post 'campaigns', to: 'campaign#create', as: 'campaign_create'
      get 'campaign/new', to: 'campaign#new', ad: 'campaign_new'
      get 'campaign/:account_id/:campaign_id', to: 'campaign#show', as: 'campaign_show'
      post 'campaign/:account_id/:campaign_id/keywords', to: 'keyword#create', as: 'campaign_keywords_create'
      post 'campaign/:account_id/:campaign_id/ads', to: 'ad#create', as: 'campaign_ad_create'
      post 'campaign/:account_id/:campaign_id/ad_groups', to: 'ad_group#create', as: 'campaign_ad_group_create'

      # google account paths
      get 'account/index'
      get 'account/input'
      get 'account/select'
      get 'account/new'
      get 'account/update_time_zone', as: 'update_time_zone'
      get 'account/link', to: 'account#link'
      post 'account/create_account'
      post 'account/create_link_account'

      # google authentication paths
      get 'login/prompt'
      get 'login/callback'
      get 'login/logout'

      # google reporting paths
      get 'report/index'
      post 'report/get'
      
      # google root paths
      root 'account#index'
    end

    # global google and facebook ads paths
    root 'global_dashboard#index'
  end

  # home page path
  root 'home#index'
end
