class Ads::Google::CampaignController < Ads::Google::MasterController
  def index
    @campaigns = selected_account ? campaigns_of_specify_account(selected_account) : campains_of_all_accounts
  end

  def show
    # response = request_campaign_by_id(params[:id].to_i, params[:owner_id].to_i)
    # @campaign = Campaign.get_campaigns_list(response).first[1] if response
  end

  private

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

  def create_report_definition(date_range_type: 'LAST_7_DAYS')
    {
      :selector => {
        :fields => ['CampaignId', 'CampaignName', 'CampaignStatus', 'AccountCurrencyCode', 'Amount', 'Period', 'Impressions', 'Clicks', 'Ctr', 'AverageCpc', 'Cost', 'AdvertisingChannelType', 'ExternalCustomerId', 'CustomerDescriptiveName']
      },
      :report_name => 'CRITERIA_PERFORMANCE_REPORT',
      :report_type => 'CAMPAIGN_PERFORMANCE_REPORT',
      :download_format => 'XML',
      :date_range_type => date_range_type
    }
  end

  def get_stats_report(customer_id)
    # get client customer id before excute
    old_client_customer_id = get_client_customer_id

    set_client_customer_id(customer_id)
    report_utils = adwords.report_utils
    report_definition = create_report_definition
    result = report_utils.download_report(report_definition)

    # reset client customer id
    set_client_customer_id(old_client_customer_id)

    result
  end

  def campains_of_all_accounts
    campaigns = []
    client_accounts.each do |account_id|
      cs = campaigns_of_specify_account(account_id)
      campaigns.push(*cs)
    end
    campaigns.sort{ |a, b| a.id <=> b.id }
  end

  def campaigns_of_specify_account(account_id)
    xml = get_stats_report(account_id)
    Campaign.get_campaign_list(xml).sort{ |a, b| a.id <=> b.id }
  end
end
