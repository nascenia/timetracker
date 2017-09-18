class EmployeesController < ApplicationController
  before_action :authenticate_user!

  layout 'time_tracker'

  def index
    @employees = User.all.active.published.order(name: :asc)
    @employees = @employees.where('lower(name) LIKE ?', "%#{params[:name].strip.downcase}%") if params[:name].present?
    @employees = @employees.where('lower(email) LIKE ?', "%#{params[:email].strip.downcase}%") if params[:email].present?
  end
end
