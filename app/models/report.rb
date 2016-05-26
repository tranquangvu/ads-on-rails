class Report

  REPORT_LIST = {
    'ACCOUNT_PERFORMANCE_REPORT' => {
      :name => 'Account Performance',
      :default_fields => ['ExternalCustomerId', 'AccountDescriptiveName', 'Clicks', 'Impressions', 'Ctr', 'Conversions', 'ConversionRate', 'Cost']
    },
    'ADGROUP_PERFORMANCE_REPORT' => {
      :name => 'Adgroup Performance',
      :default_fields => ['AdGroupId', 'AdGroupName', 'AdGroupStatus', 'AccountCurrencyCode', 'CpcBid', 'Clicks', 'Impressions', 'Ctr', 'AverageCpc', 'Cost', 'AveragePosition']
    },
    'AD_PERFORMANCE_REPORT' => {
      :name => 'Ad Performance',
      :default_fields => ['Headline', 'Description1', 'Description2', 'DisplayUrl', 'CreativeFinalUrls', 'AdGroupName', 'Status', 'Labels', 'InteractionRate', 'AdType', 'Clicks', 'Impressions', 'Ctr', 'AverageCpc', 'Cost', 'AveragePosition']
    },
    'CAMPAIGN_PERFORMANCE_REPORT' => {
      :name => 'Campaign Performance',
      :default_fields => ['CampaignId', 'CampaignName', 'CampaignStatus', 'AccountCurrencyCode', 'Amount', 'Period', 'Impressions', 'Clicks', 'Ctr', 'AverageCpc', 'Cost', 'AdvertisingChannelType', 'ExternalCustomerId', 'CustomerDescriptiveName']
    },
    'KEYWORDS_PERFORMANCE_REPORT' => {
      :name => 'Keywords Performance',
      :default_fields => ['Id', 'Criteria', 'AdGroupName', 'Status', 'SystemServingStatus', 'CpcBid', 'Clicks', 'Impressions', 'Ctr', 'AverageCpc', 'Cost', 'AveragePosition', 'Labels']
    }
  }

  DATE_RANGE_TYPES = {
    'TODAY' => 'Today',
    'YESTERDAY' => 'Yesterday',
    'LAST_7_DAYS' => 'Last 7 days',
    'LAST_WEEK' => 'Last week',
    'LAST_BUSINESS_WEEK' => 'Last besiness week',
    'THIS_MONTH' => 'This month',
    'LAST_MONTH' => 'Last month',
    'ALL_TIME' => 'All time',
    'CUSTOM_DATE' => 'Custom date',
    'LAST_14_DAYS' => 'Last 14 days',
    'LAST_30_DAYS' => 'Last 30 days',
    'THIS_WEEK_SUN_TODAY' => 'This week sun today',
    'THIS_WEEK_MON_TODAY' => 'This week mon today',
    'LAST_WEEK_SUN_SAT' => 'Last week sun sat'
  }

  DEFAULT_DATE_RANGE_TYPE = 'LAST_7_DAYS'

  attr_reader :type, :name, :fields

  def initialize(type, name, fields)
    @type = type
    @name = name
    @fields = fields
  end

  def self.report_for_type(report_type)
    reports.find{ |x| x.type == report_type }
  end

  def self.reports
    @@reports ||= get_reports
  end

  def self.create_definition(template, data)
    result = template.dup()
    result[:selector][:fields] = data[:fields]
    result[:report_type] = data[:type]
    result[:download_format] = data[:format]
    return result
  end

  private
    def self.get_reports
      reports = []
      REPORT_LIST.each do |k, v|
        reports.push(Report.new(k, v[:name], v[:default_fields]))
      end
      reports
    end
end
