module GoogleAd extend ActiveSupport::Concern
  def build_api_ads(ad)
    [
      {
        :xsi_type => 'TextAd',
        :headline => ad[:headline],
        :description1 => ad[:description1],
        :description2 => ad[:description2],
        :final_urls => ad[:final_urls],
        :display_url => ad[:display_url]
      }
    ]
  end

  def add_text_ads(ad, ad_group_id, account_id)
    # get api service
    adwords = get_adwords_api
    ad_group_ad_srv = adwords.service(:AdGroupAdService, get_api_version)

    # create text ads.
    text_ads = build_api_ads(ad)

    # create ad 'ADD' operations.
    text_ad_operations = text_ads.map do |text_ad|
      {
        :operator => 'ADD',
        :operand => {:ad_group_id => ad_group_id, :ad => text_ad}
      }
    end

    # add ads.
    oci = adwords.credential_handler.credentials[:client_customer_id]
    adwords.credential_handler.set_credential(:client_customer_id, account_id)
    response = ad_group_ad_srv.mutate(text_ad_operations)
    adwords.credential_handler.set_credential(:client_customer_id, oci)

    # result
    if response and response[:value]
      return response[:value]
    else
      raise StandardError, 'No ads were added.'
    end
  end
end
