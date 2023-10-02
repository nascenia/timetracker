# :nodoc:
class ProjectsController < ApplicationController
  layout 'timetracker'

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
    @is_admin = 0
    if current_user.has_admin_privilege?
      @is_admin = 1
    end
    if params[:is_active] == 'false'
      @projects = Project.all.where(is_active: false)
      @is_active = false
    else
      @projects = Project.all.where(is_active: true)
      @is_active = true
    end
  end

  def new
    @project = Project.new
  end

  def dashboard
    @timesheets = []

    unless params[:project].present?
      return
    end

    timesheets = Timesheet.where(date: Date.parse(params[:project][:start_date])..Date.parse(params[:project][:end_date]))
    project_ids = timesheets.map{ |t| t.project_id }.uniq.sort
    user_ids = timesheets.map{ |t| t.user_id }.uniq.compact.sort

    projects = []
    case params[:project][:status]
    when 'active'
      projects = Project.active
    when 'inactive'
      projects = Project.inactive
    else
      projects = Project.find project_ids
    end
    
    users = User.find user_ids
    
    projects.each do |project|
      project_timesheets = timesheets.select{ |t| t.project_id == project.id }

      item = Hash.new
      item[:id] = project.id
      item[:project_name] = project.project_name
      item[:total_hours] = (project_timesheets.map{ |ts| 60 * ts.hours + ts.minutes }.sum / 60).round(2)
      item[:status] = project.is_active ? 'Active' : 'Inactive'
      item[:users] = []

      project_user_ids = project_timesheets.map(&:user_id).uniq.compact.sort

      project_user_ids.each do |u_id|
        user = users.find{|user| user.id == u_id}
        u_hash = {
          id: u_id,
          name: user.name,
          email: user.email,
          total_hours: (project_timesheets.select{ |pt| pt.user_id == u_id }.map{ |ts| 60 * ts.hours + ts.minutes }.sum / 60).round(2)
        }

        item[:users] << u_hash
      end

      @timesheets << item
    end
  end
  
  def summary
    timesheets = Timesheet.where(date: Date.parse(params[:project][:start_date])..Date.parse(params[:project][:end_date]))
    project_ids = timesheets.map{ |t| t.project_id }.uniq.compact.sort
    user_ids = timesheets.map{ |t| t.user_id }.uniq.compact.sort
    
    projects = Project.find project_ids
    users = User.find user_ids

    @project_summaries = []

    users.each do |user|
      user_projects = timesheets.select{ |ts| ts.user_id == user.id }
      summary = Hash.new
      summary[:user_name] = user.name
      summary[:total_hours] = (user_projects.map{ |ts| 60 * ts.hours + ts.minutes }.sum / 60).round(2)
      summary[:projects] = []
      project_ids = user_projects.map{ |ts| ts.project_id }.uniq.compact.sort

      project_ids.each do |project_id|
        project = projects.find{ |project| project.id == project_id }

        hash = Hash.new
        hash[:name] = project.project_name
        hash[:hours] = (user_projects.select{ |ts| ts.project_id == project_id }.map{ |ts| 60 * ts.hours + ts.minutes }.sum / 60).round(2)

        summary[:projects] << hash
      end

      @project_summaries << summary
    end
  end

  def show_all
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    @selected_index = params[:selected_index]
    @timesheets = Timesheet.all
    @ttf_list = User.active.where(role: 2)

    if params[:ttf_id] && params[:ttf_id] != '-1'
      users = User.active.where(ttf_id: params[:ttf_id])
      @selected_ttf_id = params[:ttf_id]
    else
      users = User.active
      @selected_ttf_id = 0
    end
    if params[:projects_id] && params[:projects_id] != '-1'
      projects = Project.all.where(is_active: true,id: params[:projects_id])
      @project_list_id = params[:projects_id]
    else
      projects = Project.all.where(is_active: true)
      @project_list_id = 0
    end
    @project_list = Project.all.where(is_active: true)

    if users.size.zero?
      users = User.active
      @selected_ttf_id = 0
    end
    @users = []
    @total_hours_project_wise = {}
    @total_minutes_project_wise = {}
    users.each do |user|
      tmp = { user: user.name, projects: [], total_sum: 0, total_sum_min: 0 }
      total_sum = 0
      total_sum_min = 0
      projects.each do |project|
        t = user.timesheets.where(project: project, date: params[:start_date]..params[:end_date])
        hours = t.sum(:hours)
        minutes = t.sum(:minutes)

        if @total_hours_project_wise[project.id].present?
          @total_hours_project_wise[project.id] += hours
          @total_minutes_project_wise[project.id] += minutes
        else
          @total_hours_project_wise[project.id] = 0
          @total_minutes_project_wise[project.id] = 0
          @total_hours_project_wise[project.id] += hours
          @total_minutes_project_wise[project.id] += minutes
        end

        if minutes >= 60
          hours += minutes/60
          minutes = minutes%60
        end

        total_sum += hours
        total_sum_min += minutes
        tmp[:projects] << { object: project, hours: hours, minutes: minutes }
      end

      if total_sum_min >= 60
        total_sum += total_sum_min/60
        total_sum_min = total_sum_min%60
      end

      tmp[:total_sum] = total_sum
      tmp[:total_sum_min] = total_sum_min
      @users << tmp
    end
  end

  def create
    if current_user.has_admin_privilege?
      @project = Project.create(project_params)
      user_ids = params[:project][:users].reject{|id| id == "0"}
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
      format.csv { 
        send_data(
          User.to_csv_timesheet(start_date: params[:start_date], end_date: params[:end_date]),
          :disposition => "attachment; filename=#{'weekly_report'.upcase}_#{Time.now.strftime('%Y%m%d%I%M%S')}.csv"
        ) 
      }
    end
  end

  def download_projects
    timesheets= Timesheet.all

    respond_to do |format|
      format.csv do
        send_data timesheets.to_csv_timesheet(start_date: params[:start_date],
                                              end_date: params[:end_date],
                                              project_id: params[:project_id])
      end
    end
  end

  def monthly_report
    @users = User.all.order(:email)

    respond_to do |format|
      format.csv { 
        send_data(
          User.to_csv_monthly_report(start_date: params[:start_date], end_date: params[:end_date]),
          :disposition => "attachment; filename=#{'monthly_report'.upcase}_#{Time.now.strftime('%Y%m%d%I%M%S')}.csv"
        ) 
      }
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
