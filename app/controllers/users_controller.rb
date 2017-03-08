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

    if user.role == User::SUPER_TTF
      @team = User.list_of_ttfs(user.id)
    elsif user.role == User::TTF
      @team = User.list_of_employees(user.id)
    else
      flash[:notice] = 'Sorry! This page is only for TTF / Super TTF!'
      redirect_to leave_user_path(current_user) and return
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
