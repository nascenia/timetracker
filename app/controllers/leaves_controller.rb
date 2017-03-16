class LeavesController < ApplicationController

  layout 'leave'

  before_action :set_leave, only: [:index, :show, :edit, :update, :destroy]
  before_action :check_permission, only: [:show, :approve]

  def index
    @my_employees = User.list_of_employees(current_user.id)
    @leaves = Leave.get_pending_leaves(current_user)
  end

  def new
    @leave = Leave.new
  end

  def create
    @leave = Leave.new(leave_params)
    @leave.user_id = current_user.id

    approval_path = current_user.approval_path
    approval_user = approval_path.path_chains.order(priority: :desc).map(&:user_id).first
    email = User.where(id: approval_user).map(&:email)

    if @leave.save
      UserMailer.send_leave_application_notification(current_user, @leave, email).deliver
      redirect_to leaves_path, :notice => 'Your TTF will be notified soon. Thanks!'
    else
      render :new
    end
  end

  def show
    respond_to do |format|
      format.html
    end
  end

  def approve
    status = Leave::ACCEPTED if params[:status] == 'accept'
    status = Leave::REJECTED if params[:status] == 'reject'
    @leave = Leave.includes(:user).find params[:id]
    @leave.update_attribute(:status, status)
    @leave.update_leave_tracker

    UserMailer.send_approval_or_rejection_notification(@leave).deliver
    redirect_to leave_path(@leave), :notice => 'Applicant shall be notified soon. Thanks!'
  end

  private

  def set_leave
    @leave = params[:id].present? ? Leave.find(params[:id]) : Leave.new
  end

  def check_permission
    @leave = Leave.find params[:id]
    unless @leave.user.ttf_id == current_user.id || @leave.user.sttf_id == current_user.id
      redirect_to leave_user_path(current_user), :notice => 'Access Denied'
    end
  end

  def leave_params
    params.require(:leave).permit(:approval_path_id, :user_id, :reason, :leave_type, :pending_at, :status, :start_date,
                                  :end_date, :half_day)
  end
end
