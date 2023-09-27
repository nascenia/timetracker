class TimesheetsController < ApplicationController
  layout 'timetracker'

  def show
    @is_editable = 0
    # if params[:selected_index]
    #     @selected_index =0
    # else
    @selected_index = params[:selected_index]
    # end
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    @project_id = params[:project_id]
    @timesheets = Timesheet.where(user_id: params[:id], project_id: params[:project_id],
                                  date: params[:start_date]..params[:end_date]).order(date: :desc)
    @username = User.find(params[:id])
    if @username == current_user
      @is_editable = 1
    end
    @number_span = {}
    @daily_total_time = {}
    @timesheets.each do |timesheet|
      daily_total_time_in_min = (timesheet.hours * 60).to_i + timesheet.minutes.to_i
      if @number_span[timesheet.date].present?
        @number_span[timesheet.date] = @number_span[timesheet.date] + 1
      else
        @number_span[timesheet.date] = 1
      end
      if @daily_total_time[timesheet.date].present?
        @daily_total_time[timesheet.date] = @daily_total_time[timesheet.date].to_i + daily_total_time_in_min
      else
        @daily_total_time[timesheet.date] = daily_total_time_in_min
      end
    end
  end

  def index
    start_date = Time.now.strftime("%Y-%m-%d") 
    end_date = Time.now.strftime("%Y-%m-%d") 
    start_date = params[:timesheet][:start_date] unless params[:timesheet].blank?
    end_date = params[:timesheet][:end_date] unless params[:timesheet].blank?

    @timesheets = Timesheet.where(user_id: current_user.id, date: Date.parse(start_date)..Date.parse(end_date)).order(date: :desc)

    @number_span = {}
    @daily_total_time = {}

    @timesheets.each do |timesheet|
      daily_total_time_in_min = (timesheet.hours * 60).to_i + timesheet.minutes.to_i

      if @number_span[timesheet.date].present?
        @number_span[timesheet.date] = @number_span[timesheet.date] + 1
      else
        @number_span[timesheet.date] = 1
      end

      if @daily_total_time[timesheet.date].present?
        @daily_total_time[timesheet.date] = @daily_total_time[timesheet.date].to_i + daily_total_time_in_min
      else
        @daily_total_time[timesheet.date] = daily_total_time_in_min
      end
    end
  end

  def new
    @timesheet = Timesheet.new
    @is_from_attent = 0

    if session[:is_from_checkout] == 1
      @is_from_attent = 1
      session[:is_from_checkout] = 0
      session[:should_force_check_out] = 1
    else
      session[:should_force_check_out] = 0
    end

    projects = current_user.projects

    @projects = Project.where.not(id: current_user.projects).where(is_active: true)
    @total_hours = 14
    user_timesheet = current_user.timesheets.where(date: Time.now.to_date)
    total_hours_hash = user_timesheet.sum(:hours)
    total_minute_hash = user_timesheet.sum(:minutes)
    @total_hours -= total_hours_hash + (total_minute_hash / 60)
    @total_mins = 3

    if @total_hours.zero?
      total_min = @total_hours * 60
      @total_mins = (total_min % 60) / 15
    end
  end

  def create
    begin
      sumhours = Timesheet.where(user_id: current_user.id, date: timesheet_params[:date].tr('/', '-')).sum(:hours).to_i
      total_sum = sumhours + timesheet_params[:hours].to_i
      if total_sum >= 15
        flash[:alert] = 'You are not allowed to enter more than 14 hours'
        redirect_to new_timesheet_path
        return
      end
    rescue Exception => e # Never do this!
      print e
    end

    if timesheet_params[:hours].to_i.zero? && timesheet_params[:minutes].to_i.zero?
      flash[:alert] = 'Hours and Minutes cannot be 0'
      redirect_to new_timesheet_path
      return
    end

    @timesheet = Timesheet.create(timesheet_params)
    @timesheet.user_id = current_user.id

    if @timesheet.date.to_date >= Time.now.to_date - 35
      if @timesheet.date.to_date <= Time.now.to_date
        if @timesheet.save
          if restrict_access?(true)
            if session[:should_force_check_out] == 1
              @attendance = session[:attendence_id].present? ? Attendance.find(session[:attendence_id]) : Attendance.new
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
              if params[:commit] == 'Submit and Add New'
                redirect_to new_timesheet_path
              else
                redirect_to root_path
              end
            else
              if params[:commit] == 'Submit and Add New'
                redirect_to new_timesheet_path
              else
                redirect_to timesheets_path(selected_index: 1, start_date: (Time.now-0.days).strftime('%Y/%m/%d'), end_date: Time.now.strftime('%Y/%m/%d'))
              end
            end
          else
            if params[:commit] == 'Submit and Add New'
              redirect_to new_timesheet_path
            else
              redirect_to timesheets_path(selected_index: 1, start_date: (Time.now-0.days).strftime('%Y/%m/%d'), end_date: Time.now.strftime('%Y/%m/%d'))
            end
          end
        else
          flash[:alert] = 'failed'
          session[:is_from_checkout] = 0
          redirect_to new_timesheet_path
        end
      else
        session[:is_from_checkout] = 0
        flash[:alert] = 'failed'
        redirect_to new_timesheet_path
      end
    else
      session[:is_from_checkout] = 0
      flash[:alert] = 'You cannot insert before 35 days'
      redirect_to new_timesheet_path
    end
  end

  def edit
    @timesheets = Timesheet.find(params[:id])
    if @timesheets.date.to_date >= Time.now.to_date - 35
      @total_hours = 14
      @projects = Project.all
      user_timesheet = current_user.timesheets.where(date: Timesheet.find(params[:id]).date)
      total_hours_hash = user_timesheet.sum(:hours)
      total_minute_hash = user_timesheet.sum(:minutes)
      @total_mins = 3
      @total_hours = (14 - (total_hours_hash + total_minute_hash / 60)) + Timesheet.find(params[:id]).hours
      if (14 - (total_hours_hash + total_minute_hash / 60) == 0)
        total_min = @total_hours * 60
        @total_mins = (total_min % 60) / 15
      end
      session[:is_from_timesheet_edit] = @timesheets.date.to_date
    else
      flash[:alert] = 'You cannot edit before 35 days'
      redirect_to timesheets_path(selected_index: 1, start_date: (Time.now - 0.days).strftime('%Y/%m/%d'), end_date: Time.now.strftime('%Y/%m/%d'))
    end
  end

  def update
    begin
      sumhours = Timesheet.where(user_id: current_user.id, date: timesheet_params[:date]. tr('/', '-')).sum(:hours).to_i
      if session[:is_from_timesheet_edit].to_s != timesheet_params[:date]
        total_sum = sumhours + timesheet_params[:hours].to_i
      else
        total_sum = sumhours
      end
      if total_sum >= 15
        flash[:alert] = 'You are not allowed to enter more than 14 hours'
        session[:is_from_timesheet_edit] = 0
        redirect_to edit_timesheet_path(timesheet_params)
        return
      end
    rescue Exception => e # Never do this!
      print e
    end

    @timesheets = Timesheet.find(params[:id])
    if timesheet_params[:date].to_date >= Time.now.to_date - 35
      if @timesheets.save && @timesheets.update(timesheet_params)
        flash[:notice] = 'Data updated sccessfully'
        redirect_to timesheets_path(selected_index: 1, start_date: (Time.now-0.days).strftime('%Y/%m/%d'), end_date: Time.now.strftime('%Y/%m/%d'))
      else
        flash[:alert] = 'failed'
        redirect_to timesheets_path(selected_index: 1, start_date: (Time.now-0.days).strftime('%Y/%m/%d'), end_date: Time.now.strftime('%Y/%m/%d'))
      end
      else
        session[:is_from_checkout] = 0
        flash[:alert] = 'You cannot update before 35 days'
        redirect_to timesheets_path(selected_index: 1, start_date: (Time.now - 0.days).strftime('%Y/%m/%d'), end_date: Time.now.strftime('%Y/%m/%d'))
      end
    end

    def timesheet_params
      params.require(:timesheet).permit(:date,
                                        :project_id,
                                        :task,
                                        :ticket_number,
                                        :ticket_link,
                                        :hours,
                                        :minutes,
                                        :description)
    end

    def restrict_access?(flag = false)
      if request.remote_ip.present?
        unless Attendance::IP_WHITELIST.include? request.remote_ip
          if flag == false
            flash[:alert] = 'Check in or out is restricted from outside office.'
          end
          false
        else
          true
        end
      end
    end
end
