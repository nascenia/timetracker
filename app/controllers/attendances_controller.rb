class AttendancesController < ApplicationController

  before_action :set_attendance, only: [:index, :edit, :update, :destroy]
  before_action :authenticate_user!

  layout 'time_tracker'

  def index
    # user = User.all.active.includes(:attendances).where('checkin_date >= ? AND checkin_date <= ? AND parent_id IS NULL',
    # Date.today.at_beginning_of_month.strftime('%Y-%m-%d'), Date.today.strftime('%Y-%m-%d')).references(:attendances)
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
    unless !restrict_access?
      @user = current_user
      attendance = @user.attendances.where(checkin_date: Time.now.strftime('%y-%m-%d')).first

      unless attendance
        Attendance.create_attendance(@user.id, nil)
        Attendance.add_missing_checkout_hours
      else
        Attendance.create_attendance(@user.id, attendance)
      end

      flash[:notice] = 'Successfully checked in.'
    end

    respond_to do |format|
      format.html {
        redirect_to :back
      }
    end
  end

  def update
    unless !restrict_access?
      if params[:id] == 'invalid'
        flash[:notice] = 'You did not log in today! Please log in first!'
        redirect_to :attendances and return
      end

      @today_entry = Attendance.find_first_entry(current_user.id, Date.today)

      if @attendance.user_id == current_user.id
        if @today_entry
          @attendance.out_time = Time.now.to_s(:time)
          @attendance.save!
          total_hours = ((@attendance.out_time.to_time - @attendance.in_time.to_time) / 1.hour).round(2)
          @attendance.total_hours = total_hours
          @attendance.save!
          flash[:notice] = 'Successfully checked out.'
        else
          flash[:notice] = 'You did not log in today.'
        end
      end
    end

    respond_to do |format|
      format.html { redirect_to :back }
    end
  end

  def destroy
    @attendance.destroy

    respond_to do |format|
      format.html { redirect_to :back }
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

  def download
    @attendances = Attendance.last_six_months

    respond_to do |format|
      format.xls {send_data @attendances.to_csv(col_sep: "\t") }
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

    def restrict_access?
      if request.remote_ip.present?
        unless (Attendance::IP_WHITELIST.include? request.remote_ip)
          flash[:notice] = 'Check in or out is restricted from outside office.'

          return false
        else
          return true
        end
      end
    end
end
