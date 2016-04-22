#require 'zuck'

class Ads::Facebook::MasterController < ApplicationController
  before_action :authenticate_user!
  before_filter :authenticate
  
  def index
  end

  private
    def authenticate
      redirect_to ads_facebook_login_index_path
    end
end
