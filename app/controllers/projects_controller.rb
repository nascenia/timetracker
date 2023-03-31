# :nodoc:
class ProjectsController < ApplicationController
  before_action :authenticate_user!
  layout 'time_tracker'

  def show
    @project = Project.find(params[:id])
    @logs = []
    User.all.each do |user|
      @start_date = params[:start_date]
      @end_date = params[:end_date]
      @selected_index = params[:selected_index]
      timesheets = user.timesheets.where(project: @project, date: params[:start_date]..params[:end_date]).group(:user_id)
      total_hours_hash = timesheets.sum(:hours)
      total_minute_hash = timesheets.sum(:minutes)

      if total_hours_hash.present? || total_minute_hash.present?
        total_hours = total_hours_hash.values[0]
        total_minute = total_minute_hash.values[0]
        if total_minute >= 60
          total_hours += total_minute / 60
          total_minute = total_minute % 60
        end
        @logs.push(username: user.name,
                   hours: total_hours,
                   minutes: total_minute,
                   id: user.id,
                   project_id: params[:id])
        p user.name
        p total_hours
        p total_minute
      end
    end
  end

  def index
    @projects = []
    project = Project.includes(:users, :timesheets)

    if params[:status].eql?('active')
      @projects = project.active
    else
      @projects = project.inactive
    end
  end

  def new
    @project = Project.new
  end
  
  def summary
    @users = User.includes(:projects).active
    @timesheets = Hash.new

    @users.each do |user|
      project_timesheets = []

      user.projects.each do |project|
        timesheets = user.timesheets.where(project: project, date: params[:project][:start_date]..params[:project][:end_date])

        hash = Hash.new
        hash[:project_name] = project.project_name
        hash[:working_minutes] = [60 * timesheets.map{|ts| ts.hours}.sum, timesheets.map{|ts| ts.minutes}.sum].sum

        project_timesheets << hash
      end

      @timesheets[user.id] = project_timesheets
    end
  end

  def create
    if current_user.has_admin_privilege?
      @project = Project.create(project_params)
      user_ids = params[:user_ids].split(',')
      user_ids.each do |uid|
        u = User.find uid
        @project.users << u
      end
      if @project.save
        redirect_to projects_path(is_active: true)
      else
        flash[:alert] = 'failed'
        redirect_to root_path
      end
    else
      flash[:alert] = 'Only Admin Can Create'
      redirect_to projects_path(is_active: true)
    end
  end

  def edit
    @project = Project.find(params[:id])
    project_user_ids = @project.users.map(&:id)
    @active_user = User.active.where.not(id: project_user_ids)
  end

  def update
    if current_user.has_admin_privilege?
      @project = Project.find(params[:id])
      @project.users.delete_all
      user_ids = params[:user_ids].split(',')
      user_ids.each do |uid|
        u = User.find uid
        @project.users << u
      end
      if @project.save && @project.update(project_params)
        redirect_to projects_path(is_active: true)
      else
        flash[:alert] = 'failed'
        redirect_to root_path
      end
    else
      flash[:alert] = 'Only Admin Can edit'
      redirect_to projects_path(is_active: true)
    end
  end

  def weekly_report
    @users = User.all.order(:email)

    respond_to do |format|
      format.xls { send_data @users.to_csv_timesheet(start_date: params[:start_date], end_date: params[:end_date]) }
    end
  end

  def download_projects
    timesheets= Timesheet.all

    respond_to do |format|
      format.xls do
        send_data timesheets.to_csv_timesheet(start_date: params[:start_date],
                                              end_date: params[:end_date],
                                              project_id: params[:project_id])
      end
    end
  end

  def monthly_report
    @users = User.all.order(:email)

    respond_to do |format|
      format.xls { send_data @users.to_csv_monthly_report(start_date: params[:start_date], end_date: params[:end_date]) }
    end
  end

  private

  # Using a private method to encapsulate the permissible parameters is
  # a good pattern since you'll be able to reuse the same permit
  # list between create and update. Also, you can specialize this method
  # with per-user checking of permissible attributes.
  def project_params
    params.require(:project).permit(:project_name,
                                    :description,
                                    :is_active,
                                    :user_ids)
  end
end
