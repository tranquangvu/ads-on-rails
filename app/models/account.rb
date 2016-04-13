class Account
  attr_reader :customer_id, :company_name, :name, :child_accounts
  attr_accessor :parent

  def initialize(api_account)
    @customer_id = api_account[:customer_id]
    @company_name = api_account[:company_name]
    @name = api_account[:name]
    @child_accounts = []
  end

  def self.get_accounts_map(graph)
    accounts = {}
    if graph and graph[:entries]
      accounts = graph[:entries].inject({}) do |result, account|
        result[account[:customer_id]] = Account.new(account)
        result
      end
      if graph[:links]
        graph[:links].each do |link|
          parent_account = accounts[link[:manager_customer_id]]
          child_account = accounts[link[:client_customer_id]]
          child_account.parent = parent_account
          parent_account.add_child(child_account) if parent_account
        end
      end
      accounts.reject! {|id, account| !account.parent.nil?}
    end
    return accounts
  end

  def add_child(child)
    @child_accounts << child
  end

  # get all clients account from root
  def self.get_client_accounts(root)
    if root.is_a? Hash
      return get_client_accounts(root.first[1].child_accounts)
    else
      result = []
      root.each do |account|
        if account.child_accounts.empty?
          result << account
        else
          result << get_client_accounts(account)
        end
      end
      return result
    end
  end
  
end
