class Account

  CURRENCY_LIST = {
    'ARS' => 'Argentine Peso (ARS)',
    'AUD' => 'Australian Dollar (AUD A$)',
    'BOB' => 'Bolivian Boliviano (BOB)',
    'BRL' => 'Brazilian Real (BRL R$)',
    'GBP' => 'British Pound (GBP £)',
    'BGN' => 'Bulgarian Lev (BGN)',
    'CAD' => 'Canadian Dollar (CAD CA$)',
    'CLP' => 'Chilean Peso (CLP)',
    'CNY' => 'Chinese Yuan (CNY CN¥)',
    'COP' => 'Colombian Peso (COP)',
    'HRK' => 'Croatian Kuna (HRK)',
    'CZK' => 'Czech Republic Koruna (CZK)',
    'DKK' => 'Danish Krone (DKK)',
    'EGP' => 'Egyptian Pound (EGP)',
    'EUR' => 'Euro (EUR €)',
    'HKD' => 'Hong Kong Dollar (HKD HK$)',
    'HUF' => 'Hungarian Forint (HUF)',
    'INR' => 'Indian Rupee (INR Rs.)',
    'IDR' => 'Indonesian Rupiah (IDR)',
    'ILS' => 'Israeli New Sheqel (ILS ₪)',
    'JPY' => 'Japanese Yen (JPY ¥)',
    'MYR' => 'Malaysian Ringgit (MYR)',
    'MXN' => 'Mexican Peso (MXN MX$)',
    'MAD' => 'Moroccan Dirham (MAD)',
    'TWD' => 'New Taiwan Dollar (TWD NT$)',
    'NZD' => 'New Zealand Dollar (NZD NZ$)',
    'NOK' => 'Norwegian Krone (NOK)',
    'PKR' => 'Pakistani Rupee (PKR)',
    'PEN' => 'Peruvian Nuevo Sol (PEN)',
    'PHP' => 'Philippine Peso (PHP Php)',
    'PLN' => 'Polish Zloty (PLN)',
    'RON' => 'Romanian Leu (RON)',
    'RUB' => 'Russian Ruble (RUB)',
    'SAR' => 'Saudi Riyal (SAR)',
    'RSD' => 'Serbian Dinar (RSD)',
    'SGD' => 'Singapore Dollar (SGD)',
    'ZAR' => 'South African Rand (ZAR)',
    'KRW' => 'South Korean Won (KRW ₩)',
    'SEK' => 'Swedish Krona (SEK)',
    'CHF' => 'Swiss Franc (CHF)',
    'THB' => 'Thai Baht (THB)',
    'TRY' => 'Turkish Lira (TRY)',
    'UAH' => 'Ukrainian Hryvnia (UAH)',
    'AED' => 'United Arab Emirates Dirham (AED)',
    'USD' => 'US Dollar (USD $)',
    'VND' => 'Vietnamese Dong (VND ₫)'
  }

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

  def account_labels=(als)
    @account_labels = als
  end

  def self.time_zone(country_value)
    p @country_value
  end

end
