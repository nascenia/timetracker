class UsersController < ApplicationController

  def leave
    @user = User.find params[:user_id]
    @leave = Leave.new

    respond_to do |format|
      format.html {render layout: 'leave'}
    end
  end

  private

    def user_params
      params.require(:user).permit(:email, :name, :is_active)
    end
end
