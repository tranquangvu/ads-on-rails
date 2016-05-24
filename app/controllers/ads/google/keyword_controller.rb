class Ads::Google::KeywordController < Ads::Google::MasterController
  include GoogleKeyword
  
  def create
    begin
      response = add_keywords(params[:keywords].split("\r\n"), params[:ad_group_id], params[:account_id])
      flash[:success] = "Successfully add #{response.length} keywords"
      redirect_to ads_google_campaign_show_path(params[:account_id], params[:campaign_id], tab_index: 2)
    rescue StandardError => e
      flash[:error] = e.message
      redirect_to :back
    end
  end
end
