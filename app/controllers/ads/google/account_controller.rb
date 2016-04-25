class Ads::Google::AccountController < Ads::Google::MasterController
  def index()
    @selected_account = selected_account
    @accounts = selected_account ? [] : get_all_client_accounts
    @current_account = Account.get_current_account(get_account_list())
  end

  def select()
    self.selected_account = params[:account_id]
    flash[:notice] = "Selected account: %s" % selected_account
    redirect_to ads_google_account_index_path
  end

  private

  # get all accounts
  def get_account_list()
    get_accounts_graph_with_fields(['CustomerId', 'Name'])
  end

  def adwords
    get_adwords_api
  end

  def client_accounts
    result = []
    graph = get_accounts_graph_with_fields(['CustomerId'])
    if graph && graph[:links] #&& graph[:entries]
      result = graph[:links].map{ |link| link[:client_customer_id] }
      # result = graph[:entries].select{ |e| ids.include?(e[:customer_id]) }
    end
    result
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
        :fields => [
          'ExternalCustomerId',
          'AccountDescriptiveName',
          'Clicks',
          'Impressions',
          'Ctr',
          'Conversions',
          'ConversionRate',
          'Cost'
        ]
      },
      :report_name => 'ACCOUNT_PERFORMANCE_REPORT',
      :report_type => 'ACCOUNT_PERFORMANCE_REPORT',
      :download_format => 'XML',
      :date_range_type => date_range_type
    }
  end

  def get_stats_report(customer_id)
    #get client customer id before excute
    old_client_customer_id = get_client_customer_id

    set_client_customer_id(customer_id)
    report_utils = adwords.report_utils
    report_definition = create_report_definition
    adwords.include_zero_impressions = true
    result = report_utils.download_report(report_definition)

    #reset client customer id
    set_client_customer_id(old_client_customer_id)

    result
  end

  def get_all_client_accounts
    accounts = []
    client_accounts.each do |customer_id|
      sa = get_specify_account(customer_id)
      accounts.push(*sa)
    end
    accounts.sort{ |a, b| a.id <=> b.id}
  end

  def get_account_label(customer_id)
    #get all account with manager id
    customers = get_accounts_graph_with_fields(['CustomerId', 'AccountLabels'])

    result = customers[:entries].select {|hash| hash[:customer_id] == customer_id}.first
    return result[:account_labels]
  end

  def get_specify_account(customer_id)
    xml = get_stats_report(customer_id)
    account = Account.get_data_client_accounts(xml)
    als = get_account_label(customer_id)
    account.account_labels = als
    account
  end

  def get_accounts_graph_with_fields(fields)
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
