class Ads::Google::CampaignController < Ads::Google::MasterController
  before_action :init, only: [:index, :show, :create, :new]

  def index
    @selected_account = selected_account
    unless selected_account
      @all_client_accounts = all_client_accounts
      account_out_of_date_handler unless @all_client_accounts
      @selected_account_ids = params[:selected_account_ids] || @all_client_accounts.map{ |a| a[:customer_id] }
    end
    @campaigns = selected_account ? campaigns_of_specify_account(selected_account, date_range) : campains_of_list_accounts(@selected_account_ids, date_range)
    account_out_of_date_handler unless @campaigns
  end

  def show
    @tab_index = params[:tab_index].to_i || 0
    @account_id = params[:account_id]
    @campaign = get_specify_campagin(params[:account_id], params[:campaign_id], {:date_range_type => Report::DEFAULT_DATE_RANGE_TYPE})
    @ad_groups = get_ad_groups_of_campaign(params[:account_id], params[:campaign_id], date_range)
    @ads = get_ads_of_campaign(params[:account_id], params[:campaign_id], date_range)
    @keywords = get_keywords_of_campaign(params[:account_id], params[:campaign_id], date_range)
    account_out_of_date_handler if (@campaign == false || @ad_groups == false || @ads == false || @keywords == false)
  end

  def new
    @types = Campaign::TYPES.to_a.map{ |t| t.reverse }
  end

  def create
  end

  def init
    @date_range_type = params[:date_range_type] || Report::DEFAULT_DATE_RANGE_TYPE
    @custom_start_date = params[:custom_start_date] || Date.today.strftime('%Y-%m-%d')
    @custom_end_date = params[:custom_end_date] || Date.today.strftime('%Y-%m-%d')
  end

  def date_range
    {
      :date_range_type => @date_range_type,
      :min_date => Date.parse(@custom_start_date).strftime('%Y%m%d'),
      :max_date => Date.parse(@custom_end_date).strftime('%Y%m%d')
    }
  end

  private
    # =================================
    # API Handler
    # =================================
    def adwords
      get_adwords_api
    end

    def get_client_customer_id
      adwords.credential_handler.credentials[:client_customer_id]
    end

    def set_client_customer_id(customer_id)
      adwords.credential_handler.set_credential(:client_customer_id, customer_id)
    end

    # =================================
    # Acounting
    # =================================
    def account_out_of_date_handler
      [:selected_account, :token].each {|key| session.delete(key)}
      redirect_to ads_google_login_prompt_path, notice: 'Your google authentication is out of date. Authenticate again to continue.' and return
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

    def get_accounts_graph_with_fields(fields)
      adwords = get_adwords_api()
      result = nil
      begin
        # First get the AdWords manager account ID.
        customer_srv = adwords.service(:CustomerService, get_api_version())
        customer = customer_srv.get()
        adwords.credential_handler.set_credential(:client_customer_id, customer[:customer_id])

        # Then find all child accounts using that ID.
        managed_customer_srv = adwords.service(:ManagedCustomerService, get_api_version())
        selector = {:fields => fields}

        # Set result to return
        result = managed_customer_srv.get(selector)
      rescue AdwordsApi::Errors::ApiException => e
        logger.fatal("Exception occurred: %s\n%s" % [e.to_s, e.message])
        flash.now[:alert] =
            'API request failed with an error, see logs for details'
      rescue NoMethodError => e
        logger.fatal("Exception occurred: %s\n%s" % [e.to_s, e.message])
        result  = false
      end
      result
    end

    # =================================
    # Reporting
    # =================================
    def report_definition(fields, name, type, options)
      definition = {
        :selector => {
          :fields => fields
        },
        :report_name => name,
        :report_type => type,
        :download_format => 'XML',
        :date_range_type => options[:date_range][:date_range_type]
      }
      definition[:selector][:date_range] = { :min =>  options[:date_range][:min_date], :max =>  options[:date_range][:max_date] } if  options[:date_range][:date_range_type].eql?('CUSTOM_DATE') &&  options[:date_range][:min_date] &&  options[:date_range][:max_date]
      definition[:selector][:predicates] = options[:predicates] if options[:predicates]
      definition
    end

    def get_report_by_xml(customer_id, report_definition)
      oci = get_client_customer_id
      set_client_customer_id(customer_id)
      report_utils = adwords.report_utils
      result = report_utils ? report_utils.download_report(report_definition) : nil
      set_client_customer_id(oci)
      result
    end

    def campaigns_of_specify_account(account_id, date_range)
      fields = ['CampaignId', 'CampaignName', 'CampaignStatus', 'AccountCurrencyCode', 'Amount', 'Period', 'Impressions', 'Clicks', 'Ctr', 'AverageCpc', 'Cost', 'AdvertisingChannelType', 'ExternalCustomerId', 'CustomerDescriptiveName']
      name = 'CAMPAIGN_PERFORMANCE_REPORT'
      type = 'CAMPAIGN_PERFORMANCE_REPORT'
      report_definition = report_definition(fields, name, type, {:date_range => date_range})
      xml = get_report_by_xml(account_id, report_definition)
      xml ? Campaign.get_campaign_list(xml).sort{ |a, b| a.id <=> b.id } : false
    end

    def campains_of_list_accounts(client_account_ids, date_range)
      campaigns = []
      client_account_ids.each do |account_id|
        cs = campaigns_of_specify_account(account_id, date_range)
        campaigns.push(*cs) if cs
      end
      campaigns.empty? ? false : campaigns.sort{ |a, b| a.id <=> b.id }
    end

    def get_specify_campagin(account_id, campaign_id, date_range)
      fields = ['CampaignId', 'CampaignName', 'CampaignStatus', 'AccountCurrencyCode', 'Amount', 'Period', 'AdvertisingChannelType']
      name = 'CAMPAIGN_PERFORMANCE_REPORT'
      type = 'CAMPAIGN_PERFORMANCE_REPORT'
      report_definition = report_definition(fields, name, type, {
        :date_range => date_range,
        :predicates => {
          :field => 'CampaignId',
          :operator => 'EQUALS',
          :values => [campaign_id]
        }
      })
      xml = get_report_by_xml(account_id, report_definition)
      xml ? Campaign.get_campaign(xml) : false
    end

    def get_ad_groups_of_campaign(account_id, campaign_id, date_range)
      fields = ['AdGroupId', 'AdGroupName', 'AdGroupStatus', 'AccountCurrencyCode', 'CpcBid', 'Clicks', 'Impressions', 'Ctr', 'AverageCpc', 'Cost', 'AveragePosition']
      name = 'ADGROUP_PERFORMANCE_REPORT'
      type = 'ADGROUP_PERFORMANCE_REPORT'
      report_definition = report_definition(fields, name, type, {
        :date_range => date_range,
        :predicates => {
          :field => 'CampaignId',
          :operator => 'EQUALS',
          :values => [campaign_id]
        }
      })
      xml = get_report_by_xml(account_id, report_definition)
      xml ? AdGroup.get_ad_groups(xml) : false
    end

    def get_ads_of_campaign(account_id, campaign_id, date_range)
      fields = ['Headline', 'Description1', 'Description2', 'DisplayUrl', 'CreativeFinalUrls', 'AdGroupName', 'Status', 'Labels', 'InteractionRate', 'AdType', 'Clicks', 'Impressions', 'Ctr', 'AverageCpc', 'Cost', 'AveragePosition']
      name = 'AD_PERFORMANCE_REPORT'
      type = 'AD_PERFORMANCE_REPORT'
      report_definition = report_definition(fields, name, type, {
        :date_range => date_range,
        :predicates => {
          :field => 'CampaignId',
          :operator => 'EQUALS',
          :values => [campaign_id]
        }
      })
      xml = get_report_by_xml(account_id, report_definition)
      xml ? Ad.get_ads(xml) : false
    end

    def get_keywords_of_campaign(account_id, campaign_id, date_range)
      fields = ['Id', 'Criteria', 'AdGroupName', 'Status', 'SystemServingStatus', 'CpcBid', 'Clicks', 'Impressions', 'Ctr', 'AverageCpc', 'Cost', 'AveragePosition', 'Labels']
      name = 'KEYWORDS_PERFORMANCE_REPORT'
      type = 'KEYWORDS_PERFORMANCE_REPORT'
      report_definition = report_definition(fields, name, type, {
        :date_range => date_range,
        :predicates => {
          :field => 'CampaignId',
          :operator => 'EQUALS',
          :values => [campaign_id]
        }
      })
      xml = get_report_by_xml(account_id, report_definition)
      xml ? Keyword.get_keywords(xml) : false
    end
end
