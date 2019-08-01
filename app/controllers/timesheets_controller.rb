class TimesheetsController < ApplicationController
    layout 'time_tracker'
    def index
        @timesheets = Timesheet.all
        @projects = Project.all

    end
    def new
        @projects = Project.all
        @timesheet = Timesheet.new
    end
    def create
        p '###################'
        p current_user
        @timesheet = Timesheet.create(timesheet_params)
        @timesheet.user_id = current_user.id
        if @timesheet.save
            redirect_to timesheets_path
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
