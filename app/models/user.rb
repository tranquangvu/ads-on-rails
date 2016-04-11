class User < ActiveRecord::Base
  attr_accessor :current_step

  ADVERTISER_TYPES = %w(Agency/Consultant In-house)
  TARGET_AUDIENCE = [ "I sell to businesses (B2B)", "I sell to consumers (B2C)", "Both"]  
  AVERAGE_MONTHLY_SPEND = ["Under $2500", "$2500 - $10000", "$10000 - $50000", "$50000 - $100000", "Over $100000"]

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :username, presence: true, length: { minimum: 3, maximum: 16 }
  validates :company_name, presence: true,  if: -> { on_step?([:ads_profile_creation]) }
  validates :advertiser_type_id, :target_audience_id, :monthly_spend_id, presence: true, if: -> { on_step?([:ads_profile_creation]) }

  def on_step?(steps)
    steps.include?(current_step)
  end
end
