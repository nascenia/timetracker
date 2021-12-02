class GoalsController < ApplicationController

  layout 'time_tracker'

  before_action :set_goal, only: [:show, :edit, :update, :destroy]

  # GET /goals
  def index
    user_id = params.blank? ? current_user.id : params[:user_id]
    @goals  = Goal.search(params[:goal], user_id)
    @team   = User.active.where(ttf: current_user)
  end

  # GET /goals/1
  def show
  end

  # GET /goals/new
  def new
    @goal             = Goal.new
    @goal_categories  = GoalCategory.where(published: true)
    @team             = User.active.where(ttf: current_user)
    @goals            = []
    @goals            = Goal.search(params, params[:user_id]) unless params[:user_id].blank?
  end

  # GET /goals/1/edit
  def edit
  end

  # POST /goals
  def create
    @goal = Goal.new(goal_params)

    if @goal.save
      redirect_to new_goal_path(user_id: goal_params[:user_id], time_period: params[:goal][:time_period], start_date: goal_params[:start_date], end_date: goal_params[:end_date]), notice: 'Goal was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /goals/1
  def update
    if @goal.update(goal_params)
      redirect_to goals_url, notice: 'Goal was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /goals/1
  def destroy
    @goal.destroy
    redirect_to goals_url, notice: 'Goal was successfully destroyed.'
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_goal
    @goal = Goal.find(params[:id])
  end

  def goal_params
    params.require(:goal).permit(
      :user_id,
      :goal_category_id,
      :reviewer_id,
      :title,
      :description,
      :point,
      :percent_completed,
      :achived_point,
      :deliverable_link,
      :comments,
      :start_date,
      :end_date,
      :status
    )
  end
end

