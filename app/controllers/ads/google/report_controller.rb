class Ads::Google::ReportController < Ads::Google::MasterController
  
  REPORT_DEFINITION_TEMPLATE = {
    :selector => {
      :fields => []
    },
    :report_name => 'AdWords on Rails report',
    :report_type => nil,
    :download_format => nil,
    :date_range_type => 'LAST_7_DAYS'
  }

  def index
    if selected_account
      @current_account = current_account
      account_out_of_date_handler unless @current_account
    else
      @all_client_accounts = all_client_accounts
      account_out_of_date_handler unless @all_client_accounts
    end
    @reports = Report.reports
    @formats = ReportFormat.report_formats
  end

  def get
    # get seleted is array
    selected_id = selected_account ? selected_account : params[:selected_account_ids].to_i

    # get choosed report type
    report = Report.report_for_type(params[:type])

    # get choosed report format
    format = ReportFormat.report_format_for_type(params[:format])

    begin
      # build definition
      api = get_adwords_api()
      report_utils = api.report_utils()
      definition = Report.create_definition(REPORT_DEFINITION_TEMPLATE, {
          :fields => report.fields,
          :type => report.type,
          :format => format.type
        })
      api.include_zero_impressions = true

      # send report to client to save
      report_data = report_utils.download_report(definition, selected_id)
      send_data(report_data, {:filename => format.file_name(report), :type => format.content_type})
    rescue AdwordsApi::Errors::ReportError => e
      flash.now[:error] = e.message
    end
  end

  private
    def current_account
      graph = get_accounts_graph_with_fields(['CustomerId', 'Name'])
      if graph != false
        Account.get_current_account(graph)
      else
        return false
      end
    end

    def all_client_accounts
      result = []
      graph = get_accounts_graph_with_fields(['CustomerId', 'Name'])
      if graph != false
        if graph[:links] && graph[:entries]
          ids = graph[:links].map{ |link| link[:client_customer_id] }
          result = graph[:entries].select{ |e| ids.include?(e[:customer_id]) }
        end
        return result
      else
        return false
      end
    end

    def get_accounts_graph_with_fields(fields)
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
        logger.fatal("Exception aaa occurred: %s\n%s" % [e.to_s, e.message])
        result = false
      end
      result
    end

    def account_out_of_date_handler
      [:selected_account, :token].each {|key| session.delete(key)}
      redirect_to ads_google_login_prompt_path, notice: 'Your google authentication is out of date. Authenticate again to continue.' and return
    end
end
