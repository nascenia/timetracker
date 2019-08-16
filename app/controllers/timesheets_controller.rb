class TimesheetsController < ApplicationController
    layout 'time_tracker'
    def show

        # if params[:selected_index]
        #     @selected_index =0
        # else
            @selected_index = params[:selected_index]
        # end
        @start_date = params[:start_date]
        @end_date = params[:end_date]
        @project_id = params[:project_id]
        @timesheets= Timesheet.where(user_id: params[:id],project_id: params[:project_id],date: params[:start_date]..params[:end_date])
        @username = User.find(params[:id])
    end
    def index
        @selected_index = params[:selected_index]
        @start_date = params[:start_date]
        @end_date = params[:end_date]
        @timesheets = Timesheet.all.where(user_id: current_user.id,date: params[:start_date]..params[:end_date])
        @projects = Project.all
        @user= current_user

    end
    def new
        projects = current_user.projects
        p '#####CU project'
        projects.each do |project|
            p project
        end
        p '#####CU project'
        @projects = Project.where.not(id: current_user.projects)
        @projects.each do |pr|
        @total_hours = 14;
        end
        user_timesheet = current_user.timesheets.where(date: Time.now.to_date)
        total_hours_hash=user_timesheet.sum(:hours)
        total_minute_hash=user_timesheet.sum(:minutes)
            @total_hours -= total_hours_hash

        @timesheet = Timesheet.new
    end
    def create
        @timesheet = Timesheet.create(timesheet_params)
        @timesheet.user_id = current_user.id
        if @timesheet.date.to_date <= Time.now.to_date
            if @timesheet.save
                redirect_to root_path
            else
                flash[:alert] = 'failed'
                redirect_to root_path
            end
        else
            flash[:alert] = 'failed'
            redirect_to root_path
            end
    end

    def edit
        @timesheets = Timesheet.find(params[:id])
        @projects = Project.all
    end

    def update
        @timesheets = Timesheet.find(params[:id])
        if @timesheets.save && @timesheets.update(timesheet_params)
            redirect_to timesheets_path
        else
            flash[:alert] = 'failed'
            redirect_to root_path
        end

    end
    def timesheet_params
        params.require(:timesheet).permit(:date,:project_id,:task,
                                         :ticket_number,:ticket_link,:hours,:minutes,:description )
    end
end
