class ApprovalChainsController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :find_user, only: [:show, :create_chain]
  layout 'leave'

  def index
    @users = User.all.active

    respond_to do |format|
      format.html
    end
  end

  def show
    @users = User.where.not(id: current_user)
    @approval_paths = @user.approval_paths.includes(:path_chains)

    respond_to do |format|
      format.html
    end
  end

  def create_chain
    path = @user.approval_paths.create(active: true)

    approval_chain = params[:chain]
    max_priority = approval_chain.size

    approval_chain.each do |user_id|
      path_chain = path.path_chains.build
      path_chain.user_id = user_id
      path_chain.priority = max_priority
      max_priority = max_priority - 1
      path_chain.save
    end

    redirect_to approval_chain_path(@user)
  end

  private

  def find_user
    @user = User.find_by(id: params[:id])
  end
end
