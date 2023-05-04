class GoalsController < ApplicationController

  layout 'time_tracker'

  before_action :set_goal, only: [:show, :edit, :update, :destroy]

  # GET /goals
  def index
    user_id = current_user.id

    if params[:goal].present? && params[:goal][:personal_or_team].eql?('team') 
      user_id = params[:goal][:team_member]
    end

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
    @goal_categories  = GoalCategory.where(published: true)
    @team             = User.active.where(ttf: current_user)
  end

  # POST /goals
  def create
    @goal = Goal.new(goal_params)

    if @goal.save
      redirect_to new_goal_path(user_id: goal_params[:user_id], time_period: params[:goal][:time_period], start_date: goal_params[:start_date], end_date: goal_params[:end_date], goal_category_id: goal_params[:goal_category_id]), notice: 'Goal was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /goals/1
  def update
    if @goal.update(goal_params)
      respond_to do |format|
        url_params = {
          personal_or_team: params[:goal][:personal_or_team],
          team_member: @goal.user_id,
          year: @goal.start_date.strftime("%Y"),
          time_period: @goal.quarter,
          start_date: @goal.start_date.strftime('%d-%m-%Y'),
          end_date: @goal.end_date.strftime('%d-%m-%Y')
        }
        format.html {
          redirect_to goals_url(goal: url_params, commit: 'Search'), notice: 'Goal was successfully updated.' 
        }
        format.js   { render json: { status: 200, notice: 'Review submitted successfully.' }}
      end
    else
      render :edit
    end
  end

  # DELETE /goals/1
  def destroy
    @goal.destroy
    redirect_to goals_url, notice: 'Goal was successfully destroyed.'
  end

  # GET /goals/review
  def review
    user_id = params[:goal].blank? ? current_user.id : params[:goal][:user_id]
    @goals  = Goal.search(params[:goal], user_id)
    @team   = User.active.where(ttf: current_user)
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

