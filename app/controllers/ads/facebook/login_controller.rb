#require 'zuck'

class Ads::Facebook::LoginController < Ads::Facebook::MasterController

  skip_before_filter :authenticate

  def index
  end
end
