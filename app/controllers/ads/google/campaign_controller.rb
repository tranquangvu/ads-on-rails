class Ads::Google::CampaignController < Ads::Google::MasterController
  
  PAGE_SIZE = 50

  def index
    if selected_account
      # get campaigns by current selected account
      response = request_campaigns_list
      if response
        @campaigns = Campaign.get_campaigns_list(response)
      end
    else
      @campaigns = {}
      
      # first get all accounts hierarchy
      accounts = get_accounts_hierarchy
      root_customer_id = accounts.first[0]

      # get all client accounts (only client accounts have campaigns)
      client_accounts = get_client_accounts(accounts)

      # get all campaigns in each client accounts
      client_accounts.each do |account|
        set_client_customer_id(account.customer_id)
        response = request_campaigns_list
        if response
          clients_campaigns = Campaign.get_campaigns_list(response)
          # set owner for campaigns
          clients_campaigns.each do |_, campaign|
            campaign.owner = account.name
          end
          # sort campaigns by key(campaign_id)
          @campaigns = Hash[@campaigns.merge!(clients_campaigns).sort]
        end
      end

      # reset client_customer_id as root
      set_client_customer_id(root_customer_id)

      puts @campaigns
    end
  end

  # get all accounts
  def get_accounts_hierarchy
    graph = get_accounts_graph_with_fields(['CustomerId', 'Name'])
    accounts = Account.get_accounts_map(graph)
  end

  private
    
    # get list campaigns of a account by current customer_id
    def request_campaigns_list
      api = get_adwords_api()
      service = api.service(:CampaignService, get_api_version())
      selector = {
        :fields => ['Id', 'Name', 'Status', 'BudgetId', 'Amount'],
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

    # set specify client_customer_id in api
    def set_client_customer_id(customer_id)
      api = get_adwords_api()
      api.credential_handler.set_credential(:client_customer_id, customer_id)
    end

    # get all clients account from root
    def get_client_accounts(root)
      if root.is_a? Hash
        return get_client_accounts(root.first[1].child_accounts)
      else
        result = []
        root.each do |account|
          if account.child_accounts.empty?
            result << account
          else
            result << get_client_accounts(account)
          end
        end
        return result
      end
    end
end
