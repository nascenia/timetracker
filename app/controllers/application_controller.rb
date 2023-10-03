class ApplicationController < ActionController::Base
  include Pagy::Backend
  
  before_action :authenticate_user!
  before_action :load_setting

  def authenticate_admin_user!
    redirect_to new_user_session_path unless current_user.try(:has_admin_privilege?)
  end

  def load_setting
    @setting = Setting.last
  end
end
