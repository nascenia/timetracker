class WeekendsController < ApplicationController

  before_action :find_weekend, only: [:show, :assign, :destroy, :edit, :update]

  layout 'leave'

  def index
    @weekends = Weekend.all
  end

  def show
    @available_users = User.has_no_weekend
    @assigned_users = @weekend.users
    @weekend_days = @weekend.off_days.map(&:capitalize)
  end

  def assign
    employees = params[:employees]
    employees.each do |employee|
      user = User.find_by(id: employee)
      user.update_attribute(:weekend, @weekend)
    end
    redirect_to weekend_path(@weekend)
  end

  def new
    @weekend = Weekend.new
  end

  def create
    @weekend = Weekend.create(weekend_params)
    redirect_to weekends_path if @weekend.save
  end

  def edit
  end

  def update
    @weekend.update(weekend_params) ? redirect_to(weekends_path) : render(:edit)
  end

  def destroy
    redirect_to weekends_path if @weekend.destroy
  end

  private

  def weekend_params
    params.require(:weekend).permit(:name, off_days: [])
  end

  def find_weekend
    @weekend = Weekend.find_by(id: params[:id])
  end
end
