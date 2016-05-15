class AdGroup
  attr_reader :id, :name, :state, :currency, :default_max_cpc, :clicks, :impressions, :ctr, :avg_cpc, :cost, :avg_position

  def initialize(api_ad_group)
    @id = api_ad_group[:id]
    @name = api_ad_group[:name]
    @state = api_ad_group[:state]
    @currency = api_ad_group[:currency]
    @default_max_cpc = api_ad_group[:default_max_cpc]
    @clicks = api_ad_group[:clicks]
    @impressions = api_ad_group[:impressions]
    @ctr = api_ad_group[:ctr]
    @avg_cpc = api_ad_group[:avg_cpc]
    @cost = api_ad_group[:cost]
    @avg_position = api_ad_group[:avg_position]
  end

  def self.get_ad_groups(xml)
    ad_groups = []
    doc = Nokogiri::Slop(xml)
    doc.xpath('//row').each do |row|
      ad_groups << AdGroup.new({
        :id => row[:adGroupID],
        :name => row[:adGroup],
        :state => row[:adGroupState],
        :currency => row[:currency],
        :default_max_cpc => row[:defaultMaxCPC],
        :clicks => row[:clicks], 
        :impressions => row[:impressions], 
        :ctr => row[:ctr], 
        :avg_cpc => row[:avgCPC], 
        :cost => row[:cost], 
        :avg_position => row[:avgPosition]
      })
    end
    ad_groups
  end
end

