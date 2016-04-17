class AfterSignupController < ApplicationController
  layout 'devise'
  
  include Wicked::Wizard
  steps :ads_profile_creation

  def show
    @user = current_user
    render_wizard
  end
  
  def update
    @user = current_user
    params[:user][:current_step] = step
    @user.update(user_params)
    render_wizard @user
  end

  def finish_wizard_path
    ads_root_path
  end

  def redirect_to_finish_wizard(options = nil)
    redirect_to finish_wizard_path , notice: "Thanks you for sign up. Welcome to BStage!"
  end

  private
    def user_params
      params.require(:user).permit(:company_name, :company_url, :advertiser_type_id, :target_audience_id, :monthly_spend_id, :current_step)
    end
end
