class Ads::Google::CampaignController < Ads::Google::MasterController
  
  PAGE_SIZE = 50
  
  def index
    @campaigns = selected_account ? get_campaigns_of_this_account : get_campaigns_of_accounts
  end

  def show
    response = request_campaign_by_id(params[:id].to_i, params[:owner_id].to_i)
    @campaign = Campaign.get_campaigns_list(response).first[1] if response
  end

  private
    # get campaigns by current selected account
    def get_campaigns_of_this_account
      campaigns = {}
      response = request_campaigns_list
      campaigns = Campaign.get_campaigns_list(response) if response
    end

    # get campaigns of accounts from root
    def get_campaigns_of_accounts
      campaigns = {}
      
      # first get all accounts hierarchy
      accounts = get_accounts_hierarchy
      root_customer_id = accounts.first[0]

      # get all client accounts (only client accounts have campaigns)
      client_accounts = Account.get_client_accounts(accounts)

      # get all campaigns in each client accounts
      client_accounts.each do |account|
        set_client_customer_id(account.customer_id)
        response = request_campaigns_list
        if response
          clients_campaigns = Campaign.get_campaigns_list(response)
          # set owner for campaigns
          clients_campaigns.each do |_, campaign|
            campaign.owner = { :id => account.customer_id, :name => account.name }
          end
          # sort campaigns by key(campaign_id)
          campaigns = Hash[campaigns.merge!(clients_campaigns).sort]
        end
      end

      # reset client_customer_id as root
      set_client_customer_id(root_customer_id)

      # reutrn results
      campaigns
    end

    # get list campaigns of a account by current customer_id
    def request_campaigns_list
      api = get_adwords_api()
      service = api.service(:CampaignService, get_api_version())
      selector = {
        :fields => ['Id', 'Name', 'Status', 'BudgetId', 'Amount', 'AdvertisingChannelType'],
        :ordering => [{:field => 'Id', :sort_order => 'ASCENDING'}],
        :paging => {:start_index => 0, :number_results => PAGE_SIZE}
      }
      result = nil
      begin
        result = service.get(selector)
      rescue AdwordsApi::Errors::ApiException => e
        logger.fatal("Exception occurred: %s\n%s" % [e.to_s, e.message])
        flash.now[:alert] = 'API request failed with an error, see logs for details'
      end
      return result
    end

    def request_campaign_by_id(campaign_id, owner_id)
      api = get_adwords_api()
      service = api.service(:CampaignService, get_api_version())
      old_client_customer_id = api.credential_handler.credentials[:client_customer_id]
      api.credential_handler.set_credential(:client_customer_id, owner_id)
      selector = {
        :fields => ['Id', 'Name', 'Status', 'BudgetId', 'Amount', 'AdvertisingChannelType'],
        :ordering => [{:field => 'Name', :sort_order => 'ASCENDING'}],
        :predicates => [
          {
            :field => 'Id',
            :operator => 'EQUALS',
            :values => [campaign_id]
          }
        ],
        :paging => {:start_index => 0, :number_results => PAGE_SIZE}
      }
      result = nil
      begin
        result = service.get(selector)
        api.credential_handler.set_credential(:client_customer_id, old_client_customer_id)
      rescue AdwordsApi::Errors::ApiException => e
        logger.fatal("Exception occurred: %s\n%s" % [e.to_s, e.message])
        flash.now[:alert] = 'API request failed with an error, see logs for details'
      end
      return result
    end

    # get all accounts
    def get_accounts_hierarchy
      graph = get_accounts_graph_with_fields(['CustomerId', 'Name'])
      accounts = Account.get_accounts_map(graph)
    end

    # set specify client_customer_id in api
    def set_client_customer_id(customer_id)
      api = get_adwords_api()
      api.credential_handler.set_credential(:client_customer_id, customer_id)
    end
end
