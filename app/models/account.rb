class Account
  attr_reader :id, :name, :account_labels, :clicks, :impressions, :ctr, :conversions, :convRate, :cost, :child_accounts
  attr_accessor :parent

  def initialize(api_account)
    @id = api_account[:id]
    @name = api_account[:name]
    @account_labels = api_account[:account_labels]
    @clicks = api_account[:clicks]
    @impressions = api_account[:impressions]
    @ctr = api_account[:ctr]
    @conversions = api_account[:conversions]
    @convRate = api_account[:convRate]
    @cost = api_account[:cost]
    @child_accounts = []
  end

  def account_labels=(als)
    @account_labels = als
  end

  def self.get_data_client_accounts(xml)
    data = Nokogiri::Slop(xml)
    row = data.report.table.row
    Account.new({
      :id => row[:customerID],
      :name => row[:account],
      :account_labels => row[:accountLabels],
      :clicks => row[:clicks],
      :impressions => row[:impressions],
      :ctr => row[:ctr],
      :conversions => row[:conversions],
      :convRate => row[:convRate],
      :cost => row[:cost]
    })
  end

  def self.get_current_account(graph)
    Account.new({
      :id => graph[:entries].first[:customer_id],
      :name => graph[:entries].first[:name]
    })
  end

  def add_child(child)
    @child_accounts << child
  end
end
