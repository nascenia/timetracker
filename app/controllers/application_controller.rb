class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!, :assign_salat_time

  before_action :restrict_access

  WHITELIST = ['203.202.242.130', '127.0.0.1']

  def assign_salat_time
    @salaat = Salaat.all
  end

  def restrict_access
    if request.remote_ip.present?
      unless( WHITELIST.include? request.remote_ip )
        redirect_to root_path and return false
      end
    end
  end
end
