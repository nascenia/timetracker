class AttendancesController < ApplicationController

  before_action :set_attendance, only: [:index, :show, :edit, :update, :destroy]
  before_action :restrict_access, only: [:create, :update]
  before_action :authenticate_user!

  def index
    @todays_entry = current_user.find_todays_entry
    @date = Date.today
    @todays_tracker = Attendance.todays_attendance_summary(@date)
    # @raw_data = Attendance.raw_data_of_last_six_month

    respond_to do |format|
      format.html
      # format.xls {send_data @raw_data.to_csv(col_sep: "\t") }
    end
  end

  def show
    respond_with(@attendance)
  end

  def new
    @attendance = Attendance.new
    respond_with(@attendance)
  end

  def edit
  end

  def create
    @user = current_user
    unless @user.find_todays_entry
      @user.create_attendance
      @user.add_hours_for_missing_out
    end
    @user.update_first_entry

    respond_to do |format|
      flash[:notice] = "Successfully Checked In."
      format.html {redirect_to :back}
    end
  end

  def update
    if @attendance.user_id == current_user.id
      @attendance.update_out_time
      flash[:notice] = "Successfully Checked Out."
    end

    respond_to do |format|
      format.html {redirect_to :back}
    end
  end

  def destroy
    @attendance.destroy
    respond_with(@attendance)
  end

  def search_daily_attendance
    @date = params[:date]
    @todays_tracker = Attendance.todays_attendance_summary(@date)

    respond_to do |format|
      format.js
    end
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

  def hide_name
    @user = User.find params[:id]
    @user.update_attribute(:is_active, false)

    respond_to do |format|
      format.js
    end
  end

  def show_name
    @user = User.find params[:attendance_id]
    @user.update_attribute(:is_active, true)

    respond_to do |format|
      format.js
    end
  end

  def show_hidden_names
    @users = User.inactive
  end

  private
    def set_attendance
      @attendance = params[:id].present? ? Attendance.find(params[:id]) : Attendance.new
    end

    def attendance_params
      params.permit(:user_id, :datetoday, :in_time, :out_time, :total_hours, :first_entry, :is_active)
    end
end
