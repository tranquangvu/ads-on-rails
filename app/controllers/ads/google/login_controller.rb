require 'adwords_api'

class Ads::Google::LoginController < Ads::Google::MasterController
  
  skip_before_filter :authenticate

  def prompt()
    api = get_adwords_api()
    if session[:token]
      redirect_to ads_google_account_index_path
    else
      begin
        token = api.authorize({:oauth2_callback => ads_google_login_callback_url})
      rescue AdsCommon::Errors::OAuth2VerificationRequired => e
        @login_url = e.oauth_url
      end
    end
  end

  def callback()
    api = get_adwords_api()
    begin
      session[:token] = api.authorize(
          {
            :oauth2_callback => ads_google_login_callback_url,
            :oauth2_verification_code => params[:code]
          }
      )
      flash.notice = 'Authorized successfully'
      redirect_to ads_google_account_index_path
    rescue AdsCommon::Errors::OAuth2VerificationRequired => e
      flash.alert = 'Authorization failed'
      redirect_to ads_google_login_prompt_path
    end
  end

  def logout()
    [:selected_account, :token].each {|key| session.delete(key)}
    redirect_to ads_root_path, notice: 'Log out successfully form google'
  end
end
