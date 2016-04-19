require 'adwords_api'

class Ads::Google::MasterController < Ads::AdsController
  private
  
  # Returns the API version in use.
  def get_api_version()
    return :v201509
  end

  # Returns currently selected account.
  def selected_account()
    @selected_account ||= session[:selected_account]
    return @selected_account
  end

  # Sets current account to the specified one.
  def selected_account=(new_selected_account)
    @selected_account = new_selected_account
    session[:selected_account] = @selected_account
  end

  # Checks if we have a valid credentials.
  def authenticate()
    token = session[:token]
    redirect_to ads_google_login_prompt_path if token.nil?
    return !token.nil?
  end

  # Returns an API object.
  def get_adwords_api()
    @api ||= create_adwords_api()
    return @api
  end

  # Creates an instance of AdWords API class. Uses a configuration file and
  # Rails config directory.
  def create_adwords_api()
    config_filename = File.join(Rails.root, 'config', 'adwords_api.yml')
    @api = AdwordsApi::Api.new(config_filename)
    token = session[:token]
    # If we have an OAuth2 token in session we use the credentials from it.
    if token
      credentials = @api.credential_handler()
      credentials.set_credential(:oauth2_token, token)
      credentials.set_credential(:client_customer_id, selected_account)
    end
    return @api
  end

  # get accounts graph with fields
  def get_accounts_graph_with_fields(fields)
    adwords = get_adwords_api()

    # First get the AdWords manager account ID.
    customer_srv = adwords.service(:CustomerService, get_api_version())
    customer = customer_srv.get()
    adwords.credential_handler.set_credential(
        :client_customer_id, customer[:customer_id])

    # Then find all child accounts using that ID.
    managed_customer_srv = adwords.service(
        :ManagedCustomerService, get_api_version())
    selector = {:fields => fields}
    result = nil
    begin
      result = managed_customer_srv.get(selector)
    rescue AdwordsApi::Errors::ApiException => e
      logger.fatal("Exception occurred: %s\n%s" % [e.to_s, e.message])
      flash.now[:alert] =
          'API request failed with an error, see logs for details'
    end
    return result
  end
end
