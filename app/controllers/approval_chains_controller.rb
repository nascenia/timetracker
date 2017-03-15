class ApprovalChainsController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :find_path, only: [:show, :assign]
  before_action :find_users, only: [:index, :new]
  before_action :set_path, only: [:edit, :update, :destroy]
  layout 'leave'

  def index
    @approval_paths = ApprovalPath.all.includes(:path_chains)
  end

  def show
    @users = @path.users
    @available_users = User.active.where.not(id: @users)
  end

  def new
  end

  def assign
    employees = params[:employees]

    employees.each do |employee|
      user = User.find_by(id: employee)
      user.update_attribute(:approval_path, @path)
    end

    redirect_to approval_chain_path(@path), notice: 'Path assigned for selected users'
  end

  def create_chain
    path = ApprovalPath.create(name: approval_path_params[:name])
    approval_chain = approval_path_params[:chain]
    max_priority = approval_chain.size
    if path.save
      approval_chain.each do |user_id|
        path_chain = path.path_chains.build(user_id: user_id, priority: max_priority)
        max_priority = max_priority - 1
        path_chain.save
      end
      redirect_to approval_chains_path, notice: 'Path created'
    end
  end

  def edit
    @chained_users = PathChain.find_path_chain_users(@path.id)
    @users = User.where.not( :id => @chained_users.map(&:id) )
  end

  def update
    approval_chain = approval_path_params[:chain]
    if PathChain.update(@path, approval_chain, approval_path_params[:name])
      redirect_to approval_chains_path, notice: "#{approval_path_params[:name]} updated"
    else
      redirect_to edit_approval_chain_path(path), notice: 'Update Unsuccessful'
    end
  end

  def destroy
    @path.destroy
    redirect_to approval_chains_path
  end

  private

  def approval_path_params
    params.require(:approval_path).permit(:name, chain: [])
  end

  def find_path
    @path = ApprovalPath.find_by(id: params[:id])
  end

  def find_users
    @users = User.all.active
  end

  def set_path
    @path = ApprovalPath.find(params[:id])
  end
end
