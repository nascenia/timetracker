class ApprovalChainsController < ApplicationController
  before_action :authenticate_admin_user!

  layout 'leave'

  def index
    @users = User.all.active

    respond_to do |format|
      format.html
    end
  end

  def show
    respond_to do |format|
      format.html
    end
  end

end
