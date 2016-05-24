class Ads::Google::AdController < Ads::Google::MasterController
  include GoogleAd

  def create
    ad = {
      :headline => params[:headline],
      :description1 => params[:description1],
      :description2 => params[:description2],
      :display_url => params[:display_url],
      :final_urls => [params[:final_urls]]
    }
    begin
      response = add_text_ads(ad, params[:ad_group_id], params[:account_id])
      flash[:success] = "Successfully add #{response.length} ad"
      redirect_to ads_google_campaign_show_path(params[:account_id], params[:campaign_id], tab_index: 1)
    rescue StandardError => e
      flash[:error] = e.message
      redirect_to :back
    end
  end
end
