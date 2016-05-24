class Ads::Google::AccountController < Ads::Google::MasterController
  def index
    @selected_account = selected_account
    @accounts = selected_account ? [] : get_all_client_accounts
    @current_account = Account.get_current_account(get_account_list())
  end

  def new
    @countries = Country.all
    @time_zones = TimeZone.where("country_id = ?", Country.first.id)
  end

  def update_time_zone
    country_id = Country.find_by(value: params[:country_value]).id
    @time_zones = TimeZone.where("country_id = ?", country_id).order(id: :asc)

    respond_to do |format|
      format.js
    end
  end

  def select
    self.selected_account = params[:account_id]
    flash[:notice] = "Selected account: %s" % selected_account
    redirect_to ads_google_account_index_path
  end

  def link
  end

  def create_link_account
    begin
      # Get the AdWords manager account ID.
      customer_srv = adwords.service(:CustomerService, get_api_version())
      customer_data = customer_srv.get()
      adwords.credential_handler.set_credential(:client_customer_id, customer_data[:customer_id])

      managed_customer_srv = adwords.service(:ManagedCustomerService, get_api_version())

      # Get array customer ID & format
      # example: [2754905814, 2754905814, 2754905814]
      client_customer_id = params[:account_id].split(/;/).map { |id| id.tr('-', '').to_i }

      operations = [] # List operation to create accounts

      # Create list Customers links object
      client_customer_id.each do |id|
        customer = {
          :manager_customer_id => customer_data[:customer_id],
          :client_customer_id => id,
          :link_status => 'PENDING'
        }

        # Prepare operation to create an account.
        operation = {
          :operator => 'ADD',
          :operand => customer
        }
        operations.push(operation)
      end

      managed_customer_srv.mutate_link(operations)
      redirect_to ads_google_account_index_path
    # API errors.
    rescue AdwordsApi::Errors::ApiException => e
      puts "Message: %s" % e.message
      puts 'Errors:'
      e.errors.each_with_index do |error, index|
        puts "\tError [%d]:" % (index + 1)
        error.each do |field, value|
          puts "\t\t%s: %s" % [field, value]
        end
      end
      redirect_to :back, notice: "It seems non-existent customer id. Please input exist customer ID"
    end
  end

  def create_account()
    begin
      # Get the AdWords manager account ID.
      customer_srv = adwords.service(:CustomerService, get_api_version())
      customer_data = customer_srv.get()
      adwords.credential_handler.set_credential(:client_customer_id, customer_data[:customer_id])
      
      managed_customer_srv = adwords.service(:ManagedCustomerService, get_api_version())

      # Create a local Customer object.
      customer = {
        :name => params[:name],
        :currency_code => params[:currency_code],
        :date_time_zone => params[:date_time_zone]
      }

      # Prepare operation to create an account.
      operation = {
        :operator => 'ADD',
        :operand => customer
      }

      # Create the account. It is possible to create multiple accounts with one
      # request by sending an array of operations.
      managed_customer_srv.mutate([operation])
      # response = managed_customer_srv.mutate([operation])

      # response[:value].each do |new_account|
      #   puts "Account with customer ID '%s' was successfully created." %
      #     AdwordsApi::Utils.format_id(new_account[:customer_id])
      # end

      redirect_to ads_google_account_index_path
    # Authorization error.
    rescue AdsCommon::Errors::OAuth2VerificationRequired => e
      puts "Authorization credentials are not valid. Edit adwords_api.yml for " +
          "OAuth2 client ID and secret and run misc/setup_oauth2.rb example " +
          "to retrieve and store OAuth2 tokens."
      puts "See this wiki page for more details:\n\n  " +
          'https://github.com/googleads/google-api-ads-ruby/wiki/OAuth2'

    # HTTP errors.
    rescue AdsCommon::Errors::HttpError => e
      puts "HTTP Error: %s" % e

    # API errors.
    rescue AdwordsApi::Errors::ApiException => e
      puts "Message: %s" % e.message
      puts 'Errors:'
      e.errors.each_with_index do |error, index|
        puts "\tError [%d]:" % (index + 1)
        error.each do |field, value|
          puts "\t\t%s: %s" % [field, value]
        end
      end
    end
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
    
    # data xml return nil
    unless account.nil?
      account.account_labels = als
    end

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
