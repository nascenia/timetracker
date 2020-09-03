class EmployeesController < ApplicationController
  before_action :authenticate_user!
  layout 'time_tracker'

  def index
    @pending_employees_company_emails = PreRegistration.all.where(step_no: 0..3).pluck(:companyEmail)
    @employees = User.all.order(name: :asc)
    @employees = @employees.where('lower(name) LIKE ?', "%#{params[:name].strip.downcase}%") if params[:name].present?
    @employees = @employees.where('lower(email) LIKE ?', "%#{params[:email].strip.downcase}%") if params[:email].present?
    logger.info "------------------------------------"
    logger.info params
    logger.info params[:employee_status]
    logger.info params[:name]

    if params[:employee_status].present?
      @employees = @employees.published if params[:employee_status] == '0'
      @employees = @employees.active if params[:employee_status] == '1'
      @employees = @employees.inactive if params[:employee_status] == '2'
      @employees = @employees.not_published if params[:employee_status] == '3'
      @employees = @employees.not_register if params[:employee_status] == '4'
    else
      @employees = @employees.active
    end
  end

  def show
    @user = User.find(params[:id])
    @previous_version = @user.paper_trail.previous_version
    @pre_registration = PreRegistration.where(companyEmail: @user.email).first
    @nda = nil
    if @pre_registration.present?
      @nda = @pre_registration.ndaDoc
    end
    @show_actions_to_admin = current_user.try(:has_admin_privilege?) && @user.registration_status == User::REGISTRATION_STATUS[:not_approved] ? true : false
  end

  def update_nda
    pre_registration = PreRegistration.where(user_id: params[:id]).first
    pre_registration.update(params.require(:pre_registration).permit(:ndaDoc))
    redirect_to employee_path(params[:id])
  end
end
