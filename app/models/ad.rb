class Ad
  attr_accessor :ad, :description1, :description2, :display_url, :final_url, :ad_group, :ad_state, :labels, :interaction_rate, :ad_type, :clicks, :impressions, :ctr, :avg_cpc, :cost, :avg_position

  def initialize(api_ad)
    @ad = api_ad[:ad]
    @description1 = api_ad[:description1]
    @description2 = api_ad[:description2]
    @display_url = api_ad[:display_url]
    @final_url = api_ad[:final_url]
    @ad_group = api_ad[:ad_group]
    @ad_state = api_ad[:ad_state]
    @labels = api_ad[:labels]
    @interaction_rate = api_ad[:interaction_rate]
    @ad_type = api_ad[:ad_type]
    @clicks = api_ad[:clicks]
    @impressions = api_ad[:impressions]
    @ctr = api_ad[:ctr]
    @avg_cpc = api_ad[:avg_cpc]
    @cost = api_ad[:cost]
    @avg_position = api_ad[:avg_position]
  end

  def self.get_ads(xml)
    ads = []
    doc = Nokogiri::Slop(xml)
    doc.xpath('//row').each do |row|
      ads << Ad.new({
        :ad => row[:ad],
        :description1 => row[:descriptionLine1],
        :description2 => row[:descriptionLine2],
        :display_url => row[:displayURL],
        :final_url => row[:finalURL],
        :ad_group => row[:adGroup],
        :ad_state => row[:adState],
        :labels => row[:labels],
        :interaction_rate => row[:interactionRate],
        :ad_type => row[:adType],
        :clicks => row[:clicks],
        :impressions => row[:impressions],
        :ctr => row[:ctr],
        :avg_cpc => row[:avgCPC],
        :cost => row[:cost],
        :avg_position => row[:avgPosition]
      })
    end
    ads
  end
end