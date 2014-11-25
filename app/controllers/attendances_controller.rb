class AttendancesController < ApplicationController
  before_action :set_attendance, only: [:index, :show, :edit, :update, :destroy]

  def index
    @attendances = Attendance.all
    @todays_entry = current_user.find_todays_entry
    @date = Date.today
    @todays_tracker = Attendance.todays_attendance_summary(@date)


    respond_to do |format|
      format.html
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

  private
    def set_attendance
      @attendance = params[:id].present? ? Attendance.find(params[:id]) : Attendance.new
    end

    def attendance_params
      params.permit(:user_id, :datetoday, :in, :out, :total_hours, :first_entry)
    end
end
