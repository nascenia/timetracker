class ProjectsController < ApplicationController
  layout 'time_tracker'

  def show
    @project= Project.find(params[:id])
    @logs=[]
    User.all.each do |user|
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    @selected_index = params[:selected_index]
      timesheets = user.timesheets.where(project: @project,date: params[:start_date]..params[:end_date]).group(:user_id)
      total_hours_hash=timesheets.sum(:hours)
      total_minute_hash=timesheets.sum(:minutes)

      if total_hours_hash.size > 0 || total_minute_hash.size > 0
        total_hours= total_hours_hash.values[0]
        total_minute= total_minute_hash.values[0]
        if total_minute >= 60
              total_hours += total_minute/60
              total_minute = total_minute%60
        end
        @logs.push({ username: user.name,
                     hours: total_hours,
                     minutes: total_minute,
                     id: user.id,
                   project_id: params[:id]}
        )

        p user.name
        p total_hours
        p total_minute
      end

    end

  end

  def index

    if params[:is_active] == "false"
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
  def show_all
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    @selected_index = params[:selected_index]
    @timesheets = Timesheet.all
    # projects = Project.all.where(is_active: true,date: params[:start_date]..params[:end_date])
    projects = Project.all.where(is_active: true)
    users = User.active
    @users = []
    users.each do |user|
      tmp = { user: user.name , projects: [], total_sum: 0}
      total_sum = 0
      projects.each do |project|

        t = user.timesheets.where(project: project,date: params[:start_date]..params[:end_date])

        hours = t.sum(:hours)
        minutes = t.sum(:minutes)
        if minutes >= 60
          hours += minutes/60
          minutes = minutes%60
        end
        total_sum+= hours
        tmp[:projects] << { object: project, hours: hours, minutes: minutes }
      end
      tmp[:total_sum]= total_sum
      @users << tmp
    end
  end
  def create
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

  end

  def edit
    @project = Project.find(params[:id])
    # @active_user = User.active.all.select { |u| !u.projects.map(&:id).include?(@project.id) }
    project_user_ids = @project.users.map(&:id)
    @active_user = User.active.where.not(id: project_user_ids)
    # redirect_to edit_project_path
  end
  def update
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
  end

  private
  # Using a private method to encapsulate the permissible parameters is
  # a good pattern since you'll be able to reuse the same permit
  # list between create and update. Also, you can specialize this method
  # with per-user checking of permissible attributes.
  def project_params
    params.require(:project).permit(:project_name, :description, :is_active, :user_ids)
  end
end
