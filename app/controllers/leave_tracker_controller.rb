class LeaveTrackerController < ApplicationController

  layout 'leave'

  def index

  end

  def show
    flash[:notice] = nil
    flash[:warning] = nil
    flash[:alert] = nil
    if session[:user_id].nil?
      @user = User.includes(:leaves).find params[:id]
    else
      @user = User.includes(:leaves).find session[:user_id]
      session[:user_id] = nil
    end
    @leave_tracker = @user.leave_tracker
    @leave_tracker.update_leave_tracker_daily
    if params[:month].present?
      @leaves = @user.leaves.leaves_by_month(params[:month]).order('start_date DESC')
      @month = params[:month]
    else
      @leaves = @user.leaves.order('start_date DESC')
      @month = nil
    end
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
    @leave_tracker = LeaveTracker.find(params[:id])
    if @leave_tracker.update_leave_tracker_when_awarded(params[:leave_tracker][:award_leave], params[:leave_tracker][:note])
      flash[:notice] = 'Leave awarded successfully'
      session[:user_id] = @leave_tracker.user.id
    end
    redirect_to leave_tracker_path(@leave_tracker)
  end

  def delete
  end

  def destroy
  end
end
