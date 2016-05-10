# require 'zuck'
require 'koala'

class Ads::Facebook::MasterController < ApplicationController
  before_action :authenticate_user!
  before_filter :authenticate

  private
    def authenticate
      access_token = session[:access_token]
      redirect_to ads_facebook_login_index_path if access_token.nil?
    end
end
