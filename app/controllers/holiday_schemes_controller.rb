class HolidaySchemesController < ApplicationController

  before_action :authenticate_admin_user!
  before_action :get_holiday_scheme, only: [:show, :edit, :update, :destroy, :assign_form, :assign]

  layout 'leave'

  def index
    @holiday_schemes = HolidayScheme.all
    @heading = "Holiday Schemes for #{LeaveYear.find_present_year.year}"
  end

  def show
  end

  def new
    @holiday_scheme = HolidayScheme.new
  end

  def create
    leave_year_id = LeaveYear.find_present_year.id
    holiday_scheme = HolidayScheme.new(name: params['holiday_scheme']['name'],
                                       leave_year_id: leave_year_id)
    if holiday_scheme.save
      redirect_to holiday_scheme_path(holiday_scheme)
    end
  end

  def edit
  end

  def update
    if @holiday_scheme.update_attribute(:name,params['holiday_scheme']['name'])
      redirect_to holiday_scheme_path(@holiday_scheme)
    end
  end

  def destroy
    if @holiday_scheme.destroy
      redirect_to holiday_schemes_path
    end
  end

  def assign_form
    @available_users = User.has_no_holiday_scheme
    @assigned_users = @holiday_scheme.users
    @holidays = @holiday_scheme.holidays
  end

  def assign
    employees = params[:employees]
    employees.each do |employee|
      user = User.find_by(id: employee)
      user.update_attribute(:holiday_scheme_id, @holiday_scheme.id)
    end
    redirect_to assign_form_holiday_scheme_path(@holiday_scheme)
  end

  def remove
    user = User.find(params[:id])
    user.update_attribute(:holiday_scheme_id, nil)
    redirect_to :back
  end

  private

  def holiday_scheme_params
    params.require(:holiday_scheme).permit(:name, :leave_year_id)
  end

  def get_holiday_scheme
    @holiday_scheme = HolidayScheme.find(params[:id])
  end
end
