class LeaveTrackerController < ApplicationController

  layout 'leave'

  def index

  end

  def show
    @user = User.find params[:id]

    if @user.leave_tracker.present?
      @leave_tracker = @user.leave_tracker
      @leave_tracker.update_leave_tracker_daily
    else
      LeaveTracker::create_leave_tracker(@user)
    end

    respond_to do |format|
      format.html
    end
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