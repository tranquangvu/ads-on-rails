class Ads::Google::DashboardController < Ads::Google::MasterController
  def index
    @selected_account = selected_account
  end
end
