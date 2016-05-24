module GoogleAdGroup extend ActiveSupport::Concern
  def build_api_ad_groups(ad_group)
    [
      {
        :name => ad_group[:name],
        :status => ad_group[:status],
        :campaign_id => ad_group[:campaign_id]
      }
    ]
  end

  def add_ad_groups(ad_group, account_id)
    # get api service
    adwords = get_adwords_api
    ad_group_srv = adwords.service(:AdGroupService, get_api_version)

    # create ad groups
    ad_groups = build_api_ad_groups(ad_group)

    # prepare operations for adding ad groups
    operations = ad_groups.map do |ad_group|
      {:operator => 'ADD', :operand => ad_group}
    end

    # add ad groups
    oci = adwords.credential_handler.credentials[:client_customer_id]
    adwords.credential_handler.set_credential(:client_customer_id, account_id)
    response = ad_group_srv.mutate(operations)
    adwords.credential_handler.set_credential(:client_customer_id, oci)

    # return
    if response and response[:value]
      return response[:value]
    else
      raise StandardError, 'No ad group was added'
    end
  end
end
