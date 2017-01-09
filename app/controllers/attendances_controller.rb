class AttendancesController < ApplicationController

  before_action :set_attendance, only: [:index, :edit, :update, :destroy]
  before_action :restrict_access, only: [:create, :update]
  before_action :authenticate_user!

  layout 'time_tracker'

  def index
    # user = User.all.active.includes(:attendances).where('checkin_date >= ? AND checkin_date <= ? AND parent_id IS NULL', Date.today.at_beginning_of_month.strftime('%Y-%m-%d'), Date.today.strftime('%Y-%m-%d')).references(:attendances)
    @users = User.all.active

    respond_to do |format|
      format.html
    end
  end
  
  def show
    @attendance = Attendance.includes(:children).includes(:user).find params[:id]

    respond_to do |format|
      format.html
    end
  end

  def new
    @attendance = Attendance.new

    respond_to do |format|
      format.html
    end
  end

  def edit
  end

  def create
    @user = current_user
    attendance = current_user.attendances.where(checkin_date: Time.now.strftime('%y-%m-%d')).first

    unless attendance
      @user.create_attendance nil
      @user.add_hours_for_missing_out
    else
      @user.create_attendance attendance
    end

    @user.update_first_entry
    flash[:notice] = "Successfully Checked In."

    respond_to do |format|
      format.html {
        redirect_to :back
      }
    end
  end

  def update
    if params[:id] == 'invalid'
      flash[:notice] = "You did not log in today! Please log in first!"
      redirect_to :attendances and return
    end
    @todays_entry = current_user.find_todays_entry

    if @attendance.user_id == current_user.id
      if @todays_entry
        @attendance.update_out_time
        flash[:notice] = "Successfully Checked Out."
      else
        flash[:notice] = "You did not log in today."
        render 'attendances/index'
      end
    end

    respond_to do |format|
      format.html {redirect_to :back}
    end
  end

  def destroy
    @attendance.destroy
    respond_with(@attendance)
  end

  def update_salaat_time
    data = params[:salaat]
    data.each do |salaat|
      s = Salaat.find salaat.to_a[1][:id]
      s.update_attribute(:time, salaat.to_a[1][:time])
    end
  end

  def restrict_access
    if request.remote_ip.present?
      unless (Attendance::IP_WHITELIST.include? request.remote_ip)
        flash[:notice] = 'Entry/Out is Restricted From Outside Office!'
        render 'attendances/index'

        return false
      end
    end
  end

  def six_months_data
    @users = User.all.order(:email)

    respond_to do |format|
      format.xls {send_data @users.to_csv(col_sep: "\t")}
    end
  end

  def raw_attendance_data
    @raw_data = Attendance.raw_data_of_last_six_month

    respond_to do |format|
      format.xls {send_data @raw_data.to_csv(col_sep: "\t") }
    end
  end

  def monthly_report
    respond_to do |format|
      format.js
    end
  end

  def monthly_summary
    @selected = { month: params[:user][:month], year: params[:user][:year] }
    @user = User.find params[:user][:id]
    @attendances = @user.attendances.by_month_and_year(@selected[:month], @selected[:year]).includes(:children)

    respond_to do |format|
      format.js {}
    end
  end

  private
    def set_attendance
      unless params[:id] == 'invalid'
        @attendance = params[:id].present? ? Attendance.find(params[:id]) : Attendance.new
      end
    end

    def attendance_params
      params.permit(:user_id, :checkin_date, :in_time, :out_time, :total_hours, :is_first_entry, :is_active)
    end
end
