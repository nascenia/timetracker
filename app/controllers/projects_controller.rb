class ProjectsController < ApplicationController
  layout 'time_tracker'

  def index
    @projects = Project.all
  end
  def new
    @project = Project.new
  end
  def create
    @project = Project.create(project_params)
    user_ids = params[:user_ids].split(',')
    user_ids.each do |uid|
      u = User.find uid
      @project.users << u
    end

    if @project.save
      redirect_to projects_path
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
      redirect_to projects_path
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
