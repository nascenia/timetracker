class AttendancesController < ApplicationController
  before_action :set_attendance, only: [:index, :edit, :update, :destroy]
  before_action :authenticate_user!

  layout 'timetracker'

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
    if allow_access?
      @user = current_user
      attendance = @user.attendances.where(checkin_date: Time.now.strftime('%Y-%m-%d')).first

      flash[:notice] = 'Successfully checked in.'

      if @user.all_information_provided?
        if attendance.present?
          if attendance.out_time.present?
            Attendance.create_attendance(@user.id, attendance)
          else
            flash[:notice] = 'You are already checked in.'
          end
        else
          Attendance.create_attendance(@user.id, nil)
          Attendance.add_missing_checkout_hours(@user)
        end
      else
        flash[:notice] = 'Please fill up all your details before checking in.'
      end
    end

    respond_to do |format|
      format.html {
        redirect_to root_path
      }
    end
  end

  def update
    #/users/auth/google_oauth2/callback?state=0fda7623dc84dd38452620d0adcca9b9bd89b31c90e2a4d3&code=4/fAHucfKWCPp3vS0CjsKOuTanU4T3F9NTAyM410e6VLfk15dLL7DtBskWO6xkoxgDvihoo0os3Uj5BWGKoPJz0s0&scope=email%20profile%20https://www.googleapis.com/auth/userinfo.profile%20https://www.googleapis.com/auth/userinfo.email&authuser=0&hd=nascenia.com&session_state=95aa078cf0b927a4a9bf5dd3f2f2ad4730fc1e55..ee49&prompt=none
    if allow_access?
      if params[:id] == 'invalid'
        flash[:notice] = 'You did not log in today! Please log in first!'
        redirect_to :attendances and return
      end

      @today_entry = Attendance.find_first_entry(current_user.id, Date.today)
      @timesheets = Timesheet.all.where(user_id: current_user.id, date: Date.today)

      if @timesheets.size<=0
        session[:is_from_checkout] = 1
        session[:attendence_id] = @attendance.id
        # session[:all_attendence_info] = @attendance
        flash[:alert] = 'Please fill the timesheet first'
        redirect_to new_timesheet_path and return
      else
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
    end
    respond_to do |format|
      format.html { redirect_to root_path }
    end
  end

  def destroy
    @attendance.destroy

    respond_to do |format|
      format.html { redirect_to root_path }
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

  def allow_access?
    if request.remote_ip.present? 
      if Attendance::IP_WHITELIST.include? request.remote_ip
        return true
      end
    end

    flash[:alert] = 'Check in or out is restricted from outside office.'

    return false
  end
end
