class AddMoreColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :username, :string
    add_column :users, :company_name, :string
    add_column :users, :company_url, :string
    add_column :users, :advertiser_type_id, :integer
    add_column :users, :target_audience_id, :integer
    add_column :users, :monthly_spend_id, :integer
    add_index :users, :username, unique: true
  end
end
