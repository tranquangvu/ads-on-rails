class Ads::GlobalDashboardController < Ads::AdsController
	before_filter :authenticate_user!
  
  def index
  end
end
