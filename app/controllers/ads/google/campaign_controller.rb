class Ads::Google::CampaignController < Ads::Google::MasterController
  before_action :init_state, only: [:index]

  def index
    date_range = { :date_range_type => @date_range_type }
    if @date_range_type.eql? 'CUSTOM_DATE'
      date_range[:min_date] = Date.parse(@custom_start_date).strftime('%Y%m%d')
      date_range[:max_date] = Date.parse(@custom_end_date).strftime('%Y%m%d')
    end
    @selected_account = selected_account
    @campaigns = selected_account ? campaigns_of_specify_account(selected_account, date_range) : campains_of_list_accounts(@selected_account_ids, date_range)
  end

  def show
    
  end

  def filter
    if params[:date_range_type].eql? 'CUSTOM_DATE'
      redirect_to ads_google_campaigns_path(
        :date_range_type => params[:date_range_type],
        :custom_start_date => params[:custom_start_date],
        :custom_end_date => params[:custom_end_date],
        :selected_account_ids => params[:selected_account_ids]
        )
    else
      redirect_to ads_google_campaigns_path(
        :date_range_type => params[:date_range_type],
        :selected_account_ids => params[:selected_account_ids]
        )
    end
  end

  private

  def init_state
    @date_range_type = params[:date_range_type] || Report::DEFAULT_DATE_RANGE_TYPE
    @custom_start_date = params[:custom_start_date] || Date.today.strftime('%Y-%m-%d')
    @custom_end_date = params[:custom_end_date] || Date.today.strftime('%Y-%m-%d')
    unless selected_account
      @all_client_accounts = all_client_accounts
      @selected_account_ids = params[:selected_account_ids] || @all_client_accounts.map{ |a| a[:customer_id] }
    end
  end

  def all_client_accounts
    result = []
    graph = get_accounts_graph_with_fields(['CustomerId', 'Name'])
    if graph && graph[:links] && graph[:entries]
      ids = graph[:links].map{ |link| link[:client_customer_id] }
      result = graph[:entries].select{ |e| ids.include?(e[:customer_id]) }
    end
    result
  end

  def adwords
    get_adwords_api
  end

  def get_client_customer_id
    adwords.credential_handler.credentials[:client_customer_id]
  end

  def set_client_customer_id(customer_id)
    adwords.credential_handler.set_credential(:client_customer_id, customer_id)
  end

  def create_report_definition(date_range)
    definition = {
      :selector => {
        :fields => ['CampaignId', 'CampaignName', 'CampaignStatus', 'AccountCurrencyCode', 'Amount', 'Period', 'Impressions', 'Clicks', 'Ctr', 'AverageCpc', 'Cost', 'AdvertisingChannelType', 'ExternalCustomerId', 'CustomerDescriptiveName']
      },
      :report_name => 'CAMPAIGN_PERFORMANCE_REPORT',
      :report_type => 'CAMPAIGN_PERFORMANCE_REPORT',
      :download_format => 'XML',
      :date_range_type => date_range[:date_range_type]
    }
    definition[:selector][:date_range] = { :min => date_range[:min_date], :max => date_range[:max_date] } if date_range[:date_range_type].eql?('CUSTOM_DATE') && date_range[:min_date] && date_range[:max_date]
    definition
  end

  def get_stats_report(customer_id, date_range)
    # get client customer id before excute
    old_client_customer_id = get_client_customer_id

    set_client_customer_id(customer_id)
    report_utils = adwords.report_utils
    report_definition = create_report_definition(date_range)
    result = report_utils.download_report(report_definition)

    # reset client customer id
    set_client_customer_id(old_client_customer_id)

    result
  end

  def campains_of_list_accounts(client_accounts_id, date_range)
    campaigns = []
    client_accounts_id.each do |account_id|
      cs = campaigns_of_specify_account(account_id, date_range)
      campaigns.push(*cs)
    end
    campaigns.sort{ |a, b| a.id <=> b.id }
  end

  def campaigns_of_specify_account(account_id, date_range)
    xml = get_stats_report(account_id, date_range)
    Campaign.get_campaign_list(xml).sort{ |a, b| a.id <=> b.id }
  end

  def get_accounts_graph_with_fields(fields)
    adwords = get_adwords_api()
    result = nil
    begin
      # First get the AdWords manager account ID.
      customer_srv = adwords.service(:CustomerService, get_api_version())
      customer = customer_srv.get()
      adwords.credential_handler.set_credential(
          :client_customer_id, customer[:customer_id])

      # Then find all child accounts using that ID.
      managed_customer_srv = adwords.service(
          :ManagedCustomerService, get_api_version())
      selector = {:fields => fields}

      result = managed_customer_srv.get(selector)
    rescue AdwordsApi::Errors::ApiException => e
      logger.fatal("Exception occurred: %s\n%s" % [e.to_s, e.message])
      flash.now[:alert] =
          'API request failed with an error, see logs for details'
    rescue NoMethodError => e
      [:selected_account, :token].each {|key| session.delete(key)}
      redirect_to ads_google_login_prompt_path, notice: 'Your google authentication is out of date. Login to continue.' and return nil
    end
    return result
  end
end
