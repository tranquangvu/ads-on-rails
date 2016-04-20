class Ads::Google::CampaignController < Ads::Google::MasterController
  before_action :init_state, only: [:index]

  def index
    date_range = { :date_range_type => @date_range_type }
    if @date_range_type.eql? 'CUSTOM_DATE'
      date_range[:min_date] = Date.parse(@custom_start_date).strftime('%Y%m%d')
      date_range[:max_date] = Date.parse(@custom_end_date).strftime('%Y%m%d')
    end
    @campaigns = selected_account ? campaigns_of_specify_account(selected_account, date_range) : campains_of_all_accounts(date_range)
  end

  def show
    
  end

  def select_date_range_type
    if params[:date_range_type].eql? 'CUSTOM_DATE'
      redirect_to ads_google_campaigns_path(
        :date_range_type => params[:date_range_type],
        :custom_start_date => params[:custom_start_date],
        :custom_end_date => params[:custom_end_date]
        )
    else
      redirect_to ads_google_campaigns_path(:date_range_type => params[:date_range_type])
    end
  end

  private

  def init_state
    @date_range_type = params[:date_range_type] || Report::DEFAULT_DATE_RANGE_TYPE
    @custom_start_date = params[:custom_start_date] || Date.today.strftime('%Y-%m-%d')
    @custom_end_date = params[:custom_end_date] || Date.today.strftime('%Y-%m-%d')
  end

  def client_accounts
    graph = get_accounts_graph_with_fields(['CustomerId'])
    graph[:links].map{ |link| link[:client_customer_id] }
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

  def campains_of_all_accounts(date_range)
    campaigns = []
    client_accounts.each do |account_id|
      cs = campaigns_of_specify_account(account_id, date_range)
      campaigns.push(*cs)
    end
    campaigns.sort{ |a, b| a.id <=> b.id }
  end

  def campaigns_of_specify_account(account_id, date_range)
    xml = get_stats_report(account_id, date_range)
    Campaign.get_campaign_list(xml).sort{ |a, b| a.id <=> b.id }
  end
end
