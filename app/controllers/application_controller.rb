class ApplicationController < ActionController::Base
  layout :layout_by_resource

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # return page after login in devise
  # before_filter :set_return_path

  def after_sign_in_path_for(resource)
    ads_root_path
  end

  private
    # def after_sign_in_path_for(resource) 
    #   session["user_return_to"] || root_url 
    # end

    # def set_return_path
    #   unless devise_controller? || request.xhr? || !request.get?
    #     session["user_return_to"] = request.url
    #   end
    # end

    def layout_by_resource
      devise_controller? ? "devise" : "application"
    end
end
