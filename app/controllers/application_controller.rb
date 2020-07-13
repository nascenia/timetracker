class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # before_action :assign_salat_time
  #
  # def assign_salat_time
  #   @salaat = Salaat.all
  # end
  
  @pre_registration_all = PreRegistration.where('pre_registrations.step_no = ? OR pre_registrations.step_no = ?', 2, 3)
  
  def authenticate_admin_user!
    redirect_to new_user_session_path unless current_user.try(:has_admin_privilege?)
  end
end
