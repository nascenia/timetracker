class GoalsController < ApplicationController

  layout 'time_tracker'

  before_action :set_goal, only: [:show, :edit, :update, :destroy]

  # GET /goals
  def index
    @goals = Goal.where(user: current_user)
    @team  = User.active.where(ttf: current_user)
  end

  # GET /goals/1
  def show
  end

  # GET /goals/new
  def new
    @goal             = Goal.new
    @goal_categories  = GoalCategory.where(published: true)
    @team             = User.active.where(ttf: current_user)
  end

  # GET /goals/1/edit
  def edit
  end

  # POST /goals
  def create
    @goal = Goal.new(goal_params)

    if @goal.save
      redirect_to goals_url, notice: 'Goal was successfully created.'
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

