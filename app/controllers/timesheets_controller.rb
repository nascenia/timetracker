class TimesheetsController < ApplicationController
    layout 'time_tracker'
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
        @timesheets= Timesheet.where(user_id: params[:id],project_id: params[:project_id],
                                     date: params[:start_date]..params[:end_date]).order(date: :desc)
        @username = User.find(params[:id])
        if @username == current_user
            @is_editable = 1
        end
        @number_span = {}
        @daily_total_time = {}
        @timesheets.each do |timesheet|
            daily_total_time_in_min = (timesheet.hours*60).to_i+timesheet.minutes.to_i
            if @number_span[timesheet.date].present?
                @number_span[timesheet.date] = @number_span[timesheet.date]+1
            else
                @number_span[timesheet.date] = 1
            end
            if @daily_total_time[timesheet.date].present?
                @daily_total_time[timesheet.date] = @daily_total_time[timesheet.date].to_i+daily_total_time_in_min
            else
                @daily_total_time[timesheet.date] = daily_total_time_in_min
            end
        end
    end
    def index
        @selected_index = params[:selected_index]
        @start_date = params[:start_date]
        @end_date = params[:end_date]
        @timesheets = Timesheet.all.where(user_id: current_user.id,
                                          date: params[:start_date]..params[:end_date]).order(date: :desc)
        @projects = Project.all
        @user = current_user
        @number_span = {}
        @daily_total_time = {}
        @timesheets.each do |timesheet|
            daily_total_time_in_min = (timesheet.hours*60).to_i+timesheet.minutes.to_i
            if @number_span[timesheet.date].present?
                @number_span[timesheet.date] = @number_span[timesheet.date]+1
            else
                @number_span[timesheet.date] = 1
            end
            if @daily_total_time[timesheet.date].present?
                @daily_total_time[timesheet.date] = @daily_total_time[timesheet.date].to_i+daily_total_time_in_min
            else
                @daily_total_time[timesheet.date] = daily_total_time_in_min
            end
        end
    end

    def new

        @is_from_attent = 0
        if session[:is_from_checkout] == 1
            @is_from_attent = 1
            session[:is_from_checkout] = 0
            session[:should_force_check_out] = 1
        else
            session[:should_force_check_out] = 0
        end
        projects = current_user.projects
        p '#####CU project'
        projects.each do |project|
            p project
        end
        p '#####CU project'
        @projects = Project.where.not(id: current_user.projects)
        # @projects.each do |pr|
        #
        # end
        @total_hours = 14
        user_timesheet = current_user.timesheets.where(date: Time.now.to_date)
        total_hours_hash=user_timesheet.sum(:hours)
        total_minute_hash=user_timesheet.sum(:minutes)
            @total_hours -= total_hours_hash + (total_minute_hash/60)
        @total_mins = 3
        if(@total_hours ==0)
            total_min = @total_hours*60
            @total_mins = (total_min%60)/15
        end
        @timesheet = Timesheet.new
    end
    def create
        @timesheet = Timesheet.create(timesheet_params)
        @timesheet.user_id = current_user.id
        if(@timesheet.date.to_date>=Time.now.to_date-35)
            if @timesheet.date.to_date <= Time.now.to_date
                if @timesheet.save
                    if restrict_access?
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
                            redirect_to root_path
                        else
                            if  params[:commit] == 'Submit and Add new'
                                redirect_to new_timesheet_path
                            else
                                redirect_to timesheets_path(selected_index: 1,start_date: (Time.now-0.days).strftime("%Y/%m/%d") ,end_date: Time.now.strftime("%Y/%m/%d"))

                            end
                            end
                    else
                        flash[:notice] = 'You cant logged out from outside network'
                        redirect_to timesheets_path(selected_index: 1,start_date: (Time.now-0.days).strftime("%Y/%m/%d") ,end_date: Time.now.strftime("%Y/%m/%d"))
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
        if @timesheets.date.to_date>=Time.now.to_date-35
             @total_hours = 14
             @projects = Project.all
             user_timesheet = current_user.timesheets.where(date: Timesheet.find(params[:id]).date)
             total_hours_hash=user_timesheet.sum(:hours)
             total_minute_hash=user_timesheet.sum(:minutes)
             # @total_hours -=total_hours_hash + (total_minute_hash/60)
             @total_mins = 3
             @total_hours = (14 - (total_hours_hash+total_minute_hash/60))+Timesheet.find(params[:id]).hours
             if(14 - (total_hours_hash+total_minute_hash/60) ==0)
                 total_min = @total_hours*60
                 @total_mins = (total_min%60)/15
             end
        else
            flash[:alert] = 'You cannot edit before 35 days'
            redirect_to timesheets_path(selected_index: 1,start_date: (Time.now-0.days).strftime("%Y/%m/%d") ,end_date: Time.now.strftime("%Y/%m/%d"))
        end
    end

    def update
        @timesheets = Timesheet.find(params[:id])
        if timesheet_params[:date].to_date>=Time.now.to_date-35
            if @timesheets.save && @timesheets.update(timesheet_params)
                redirect_to timesheets_path(selected_index: 1,start_date: (Time.now-0.days).strftime("%Y/%m/%d") ,end_date: Time.now.strftime("%Y/%m/%d"))
            else
                flash[:alert] = 'failed'
                redirect_to timesheets_path(selected_index: 1,start_date: (Time.now-0.days).strftime("%Y/%m/%d") ,end_date: Time.now.strftime("%Y/%m/%d"))
            end
        else
            session[:is_from_checkout] = 0
            flash[:alert] = 'You cannot update before 35 days'
            redirect_to timesheets_path(selected_index: 1,start_date: (Time.now-0.days).strftime("%Y/%m/%d") ,end_date: Time.now.strftime("%Y/%m/%d"))
        end

    end
    def timesheet_params
        params.require(:timesheet).permit(:date,:project_id,:task,
                                         :ticket_number,:ticket_link,:hours,:minutes,:description )
    end
    def restrict_access?
        if request.remote_ip.present?
            unless (Attendance::IP_WHITELIST.include? request.remote_ip)
                flash[:alert] = 'Check in or out is restricted from outside office.'

                return false
            else
                return true
            end
        end
    end
end
