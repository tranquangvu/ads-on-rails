require 'zuck'
require 'koala'

class Ads::Facebook::MasterController < ApplicationController
  before_action :authenticate_user!
  before_filter :authenticate

  private
    def authenticate
      redirect_to ads_facebook_login_index_path
    end
end
