class WeekendsController < ApplicationController

  before_action :find_weekend, only: [:show, :assign, :destroy, :edit, :update, :remove, :detail]
  before_action :find_weekend_days, only: [:show, :detail]
  before_action :find_assigned_users, only: [:show, :detail]

  layout 'leave'

  def index
    @weekends = Weekend.all
  end

  def show
    @available_users  = User.active.has_no_weekend.order(name: :asc)
    @inactive_users   = User.inactive.has_no_weekend.order(name: :asc)
  end

  def assign
    employees = params[:employees]
    employees.each do |employee|
      user = User.find_by(id: employee)
      user.update_attribute(:weekend, @weekend)
    end
    redirect_to weekend_path(@weekend)
  end

  def detail
  end

  def remove
    user = User.find(params[:id])
    user.update_attribute(:weekend_id, nil)
    redirect_to :back
  end

  def new
    @weekend = Weekend.new
  end

  def create
    @weekend = Weekend.create(weekend_params)
    @weekend.save ? redirect_to(weekends_path) : render(:new)
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

  def find_weekend_days
    @weekend_days = @weekend.off_days.map(&:capitalize)
  end

  def find_assigned_users
    @assigned_users = @weekend.users
  end
end
