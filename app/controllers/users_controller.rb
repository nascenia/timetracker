class UsersController < ApplicationController

  layout 'leave'

  before_action :authenticate_user!

  def index
    @super_ttf = User.super_ttf

    respond_to do |format|
      format.html
    end
  end

  def team
    user = User.find params[:id]

    if user.is_admin?
      @team = User.active.order(name: :asc)
    elsif user.role == User::SUPER_TTF || user.role == User::TTF || user.owned_paths.length > 0
      @team = user.get_co_workers
    else
      flash[:notice] = 'Sorry! This page is only for TTF / Super TTF!'
      redirect_to leave_tracker_path(current_user) and return
    end

    respond_to do |format|
      format.html
    end
  end

  def download
    @users = User.all.order(:email)

    respond_to do |format|
      format.xls {send_data @users.to_csv(col_sep: "\t")}
    end
  end

  private

    def user_params
      params.require(:user).permit(:email, :name, :is_active)
    end
end
