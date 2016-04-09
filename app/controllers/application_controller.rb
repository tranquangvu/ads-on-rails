class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # go to current page after login in devise
  # before_filter :set_return_path

  # private
    # def after_sign_in_path_for(resource) 
    #   session["user_return_to"] || root_url 
    # end

    # def set_return_path
    #   unless devise_controller? || request.xhr? || !request.get?
    #     session["user_return_to"] = request.url
    #   end
    # end
end
