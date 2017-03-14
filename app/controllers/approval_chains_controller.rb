class ApprovalChainsController < ApplicationController
  before_action :authenticate_admin_user!

  layout 'leave'

  def index
    @users = User.all.active
    @approval_paths = ApprovalPath.all

    respond_to do |format|
      format.html
    end
  end

  def show
    respond_to do |format|
      format.html
    end
  end

  def new
    @users = User.all.active
    @approval_paths = ApprovalPath.all
  end

  def create_chain
    path = ApprovalPath.create(name: approval_path_params[:name])

    approval_chain = approval_path_params[:chain]
    max_priority = approval_chain.size

    if path.save
      approval_chain.each do |user_id|
        path_chain = path.path_chains.build
        path_chain.user_id = user_id
        path_chain.priority = max_priority
        max_priority = max_priority - 1
        path_chain.save
      end

      redirect_to approval_chains_path, error: 'Path created'
    else
      redirect_to approval_chains_path, notice: 'Error while creating path !!!'
    end

  end

  def destroy

  end

  private

  def approval_path_params
    params.require(:approval_path).permit(:name, chain: [])
  end
end
