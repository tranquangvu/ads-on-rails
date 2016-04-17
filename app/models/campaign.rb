class Campaign
  attr_reader :id, :name, :status, :budget, :advertising_channel_type
  attr_accessor :owner

  def initialize(api_campaign)
    @id = api_campaign[:id]
    @name = api_campaign[:name]
    @status = api_campaign[:status]
    @budget = api_campaign[:budget]
    @advertising_channel_type = api_campaign[:advertising_channel_type]
  end

  def self.get_campaigns_list(response)
    result = {}
    if response[:entries]
      response[:entries].each do |api_campaign|
        campaign = Campaign.new(api_campaign)
        result[campaign.id] = campaign
      end
    end
    return result
  end
end
