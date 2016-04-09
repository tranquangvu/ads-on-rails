class RegistrationsController < Devise::RegistrationsController
  protected
  def after_sign_up_path_for(resource)
    ads_root_path
  end

  private
  def sign_up_params
    params.require(:user).permit(:email, :username, :password, :password_confirmation, :company_name, :company_url, :advertiser_type_id, :target_audience_id, :monthly_spend_id)
  end

  def account_update_params
    params.require(:user).permit(:email, :username, :password, :password_confirmation, :current_password, :company_name, :company_url, :advertiser_type_id, :target_audience_id, :monthly_spend_id)
  end
end  