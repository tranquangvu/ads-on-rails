require 'zuck'

class Ads::Facebook::AccountController < Ads::Facebook::MasterController
  before_filter :access_account

  def index
  	@accounts = Zuck::AdAccount.all
    if @accounts.empty?
      p "No Accounts"
    else
      p "#{@accounts}"
    end
  end

  private
    def access_account
      access_token = session[:access_token]
      p "#{access_token}"
      Zuck.graph = Koala::Facebook::API.new(access_token) if access_token  
    end
end
