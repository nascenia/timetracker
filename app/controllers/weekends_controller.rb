class WeekendsController < ApplicationController

  before_action :find_weekend, only: [:show, :assign, :destroy]
  layout 'leave'

  def index
    @weekends = Weekend.all
  end

  def show
    @available_users = User.has_no_weekend
    @assigned_users = User.has_weekend(params[:id])
    @weekend_days = Weekend.get_weekend_days(params[:id])
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
    @weekend = Weekend.new()
  end

  def create
    day = Weekend.get_params params
    weekend = Weekend.new(name: params['weekend']['name'].to_s, saturday: day[0], sunday: day[1],
                          monday: day[2], tuesday: day[3], wednesday: day[4],
                          thursday: day[5], friday: day[6])

    if weekend.save
      redirect_to weekends_path
    end
  end

  def edit
    @weekend = Weekend.find(params[:id])
  end

  def update
    weekend = Weekend.find(params[:id])
    if Weekend.update_weekend(weekend, params)
      redirect_to weekends_path
    end
  end

  def destroy
    assigned_users = @weekend.users
    if @weekend.destroy
      assigned_users.each do |user|
        user.update_attribute(:weekend_id, nil)
      end
    end
    redirect_to weekends_path
  end

  private

  def weekend_params
    params.require(:weekend).permit(:name, :saturday, :sunday, :monday, :tuesday,
                                    :wednesday, :thursday, :friday)
  end

  def find_weekend
    @weekend = Weekend.find_by(id: params[:id])
  end

end
