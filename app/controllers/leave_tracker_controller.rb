class LeaveTrackerController < ApplicationController

  layout 'leave'

  def index; end

  def show
    now = Time.zone.now
    debugger
    if current_user.id == params[:id].to_i || current_user.has_admin_privilege?
      if session[:user_id].nil?
        @user = User.includes(:leaves).find params[:id]
      else
        @user = User.includes(:leaves).find session[:user_id]
        session[:user_id] = nil
      end
      @leave_tracker = @user.leave_tracker
      @leave_tracker.update_leave_tracker_daily

      if params[:year].present?
        @leaves = @user.leaves.not_rollbacked_leaves.leaves_by_year(params[:year]).order('start_date DESC, created_at DESC')
      else
        @leaves = @user.leaves.not_rollbacked_leaves.order('start_date DESC, created_at DESC')
      end
      @leave = Leave.new
      @resignation_error_msg = 'The employee has Casual/ Medical leaves after Last day of working!' if @leave_tracker.casual_or_medical_leave_present_after_resignation
    else
      flash[:alert] = 'You can only see your leave'
      redirect_to leave_tracker_path(current_user)
    end
  end

  def new; end

  def create; end

  def edit; end

  def update; end

  def delete; end

  def destroy; end
end
