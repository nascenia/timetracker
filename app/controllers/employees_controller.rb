class EmployeesController < ApplicationController
  before_action :authenticate_user!
  layout 'timetracker'

  def index
    @pending_employees_company_emails = PreRegistration.all.where(step_no: 0..3).pluck(:company_email)
    @employees = User.all.order(name: :asc)

    @employees = @employees.where('lower(name) LIKE ?', "%#{params[:name].strip.downcase}%") if params[:name].present?
    @employees = @employees.where('lower(email) LIKE ?', "%#{params[:email].strip.downcase}%") if params[:email].present?

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
    @user = User.includes(:ttf, :promotions).find(params[:id])
    @pre_registration = PreRegistration.where(company_email: @user.email).first

    if @pre_registration.present?
      @nda_doc = @pre_registration.nda_doc
    else
      @nda_doc = nil
    end

    @show_actions_to_admin = current_user.try(:has_admin_privilege?) && @user.registration_status == User::REGISTRATION_STATUS[:not_approved] ? true : false
  end
end