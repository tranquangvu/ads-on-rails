class Campaign
  attr_reader :id, :name, :status, :account_currency_code, :amount, :period, :impressions, :clicks, :ctr, :average_cpc, :cost, :advertising_channel_type, :customer_id, :customer_name

  def initialize(api_campaign)
    @id = api_campaign[:id]
    @name = api_campaign[:name]
    @status = api_campaign[:status]
    @account_currency_code = api_campaign[:account_currency_code]
    @amount = api_campaign[:amount]
    @period = api_campaign[:period]
    @impressions = api_campaign[:impressions]
    @clicks = api_campaign[:clicks]
    @ctr = api_campaign[:ctr]
    @average_cpc = api_campaign[:average_cpc]
    @cost = api_campaign[:cost]
    @advertising_channel_type = api_campaign[:advertising_channel_type]
    @customer_id = api_campaign[:customer_id]
    @customer_name = api_campaign[:customer_name]
  end

  def self.get_campaign_list(xml)
    campaigns = []
    doc = Nokogiri::Slop(xml)
    unless doc.xpath('//row').empty? 
      doc.report.table.row.each do |row|
        campaigns << Campaign.new({
          :id => row[:campaignID],
          :name => row[:campaign],
          :status => row[:campaignState],
          :account_currency_code => row[:currency],
          :amount => row[:budget],
          :period => row[:budgetPeriod],
          :impressions => row[:impressions],
          :clicks => row[:clicks],
          :ctr => row[:ctr],
          :average_cpc => row[:avgCPC],
          :cost => row[:cost],
          :advertising_channel_type => row[:advertisingChannel],
          :customer_id => row[:customerID],
          :customer_name => row[:clientName]
        })
      end
    end
    campaigns
  end
end
