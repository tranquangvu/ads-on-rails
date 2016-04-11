class ApplicationController < ActionController::Base
  layout :layout_by_resource
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    ads_root_path
  end

  private
    def layout_by_resource
      devise_controller? ? "devise" : "application"
    end
end
