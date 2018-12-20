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
    @leave = Leave.new
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
