class UsersController < ApplicationController

  def leave
    @user = User.find params[:user_id]
    @leave = Leave.new
    @leave_tracker = @user.leave_tracker
    @leave_tracker.update_leave_tracker_daily

    respond_to do |format|
      format.html {render layout: 'leave'}
    end
  end

  def my_employees
    @user = User.find params[:user_id]

    if @user.role == User::SUPER_TTF
      @my_employees = User.list_of_ttfs(@user.id)
    elsif @user.role == User::TTF
      @my_employees = User.list_of_employees(@user.id)
    else
      flash[:notice] = 'Sorry! This page is only for TTF / Super TTF!'
      redirect_to user_leave_path(current_user) and return
    end

    respond_to do |format|
      format.html {render layout: 'leave'}
    end
  end

  private

    def user_params
      params.require(:user).permit(:email, :name, :is_active)
    end
end
