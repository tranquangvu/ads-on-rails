class Keyword
  attr_accessor :id, :keyword_text, :ad_group, :keyword_state, :max_cpc, :clicks, :impressions, :ctr, :avg_cpc, :cost, :avg_position, :labels

  def initialize(api_keyword)
    @id = api_keyword[:id]
    @keyword_text = api_keyword[:keyword_text]
    @ad_group = api_keyword[:ad_group]
    @keyword_state = api_keyword[:keyword_state]
    @max_cpc = api_keyword[:max_cpc]
    @clicks = api_keyword[:clicks]
    @impressions = api_keyword[:impressions]
    @ctr = api_keyword[:ctr]
    @avg_cpc = api_keyword[:avg_cpc]
    @cost = api_keyword[:cost]
    @avg_position = api_keyword[:avg_position]
    @labels = api_keyword[:labels]
  end

  def self.get_keywords(xml)
    kws = []
    doc = Nokogiri::Slop(xml)
    doc.xpath('//row').each do |row|
      kws << Keyword.new({
        :id => row[:keywordID],
        :keyword_text => row[:keyword],
        :ad_group => row[:adGroup],
        :keyword_state => row[:keywordState],
        :max_cpc => row[:maxCPC], 
        :clicks => row[:clicks],
        :impressions => row[:impressions],
        :ctr => row[:ctr],
        :avg_cpc => row[:avgCPC],
        :cost => row[:cost],
        :avg_position => row[:avgPosition],
        :labels => row[:labels]
      })
    end
    kws
  end
end