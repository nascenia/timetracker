class LeaveTrackerController < ApplicationController

  layout 'leave'

  def index

  end

  def show
    flash[:notice] = nil
    flash[:warning] = nil
    @user = User.includes(:leaves).find params[:id]
    @leave_tracker = @user.leave_tracker
    @leave_tracker.update_leave_tracker_daily
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def delete
  end

  def destroy
  end
end
