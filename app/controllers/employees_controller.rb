class EmployeesController < ApplicationController
  before_action :authenticate_user!

  layout 'time_tracker'

  def index
    if current_user.is_admin?
      @employees = User.all.order(name: :asc)
    else
      @employees = User.all.active.published.order(name: :asc)
    end
    @employees = @employees.where('lower(name) LIKE ?', "%#{params[:name].strip.downcase}%") if params[:name].present?
    @employees = @employees.where('lower(email) LIKE ?', "%#{params[:email].strip.downcase}%") if params[:email].present?
    if params[:employee_status].present?
      @employees = @employees.published if params[:employee_status] == '0'
      @employees = @employees.active if params[:employee_status] == '1'
      @employees = @employees.inactive if params[:employee_status] == '2'
    end
  end
end
