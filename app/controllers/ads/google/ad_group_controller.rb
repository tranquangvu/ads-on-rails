class Ads::Google::AdGroupController < Ads::Google::MasterController
  include GoogleAdGroup, GoogleAd, GoogleKeyword

  def create
    begin
      # add ad group
      response = add_ad_groups({
          :name => params[:ad_group_name],
          :status => 'ENABLED',
          :campaign_id => params[:campaign_id]
        }, params[:account_id])

      # get response ad groups id
      created_ad_group_id = response.first[:id]

      # add ad
      add_text_ads({
          :headline => params[:ad_group_ad_headline],
          :description1 => params[:ad_group_ad_description1],
          :description2 => params[:ad_group_ad_description2],
          :display_url => params[:ad_group_ad_display_url],
          :final_urls => [params[:ad_group_ad_final_urls]]
        }, created_ad_group_id, params[:account_id])

      # add keywords
      add_keywords(params[:ad_group_keywords].split("\r\n"), created_ad_group_id, params[:account_id])

      # return view
      flash[:success] = "Successfully add ad groups"
      redirect_to ads_google_campaign_show_path(params[:account_id], params[:campaign_id], tab_index: 0)
    rescue StandardError => e
      flash[:error] = e.message
      redirect_to :back
    end
  end
end
