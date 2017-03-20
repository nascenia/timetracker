class LeavesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_leave, only: [:index, :show, :edit]
  before_action :check_permission, only: [:show, :approve]
  before_action :find_applied_leave, only: [:approve, :reject]

  layout 'leave'

  def index
    @my_employees = User.list_of_employees(current_user.id)
    @leaves = Leave.get_leaves(current_user, params[:leave])
  end

  def new
    @leave = Leave.new
  end

  def create
    @leave = Leave.new(leave_params)
    @leave.user_id = current_user.id

    approval_user = @leave.approval_path.path_chains.order(priority: :desc).map(&:user_id).first
    email = User.where(id: approval_user).map(&:email)

    if @leave.save
      UserMailer.send_leave_application_notification(@leave, email).deliver
      redirect_to leaves_path, :notice => 'Your TTF will be notified soon. Thanks!'
    else
      render :new
    end
  end

  def show
  end

  def approve
    if @leave.pending_at == 1
      @leave.update_attributes(status: Leave::ACCEPTED, pending_at: 0)
      @leave.update_leave_tracker
      UserMailer.send_approval_or_rejection_notification(@leave).deliver
    else
      @leave.update_attribute(:pending_at, @leave.pending_at -= 1)
      email = @leave.approval_path.path_chains.find_by(priority: @leave.pending_at).user.email
      UserMailer.send_leave_application_notification(@leave, email).deliver
    end

    redirect_to leave_path(@leave), notice: 'Applicant shall be notified soon. Thanks!'
  end

  def reject
    @leave.update_attribute(:status, Leave::REJECTED)
    UserMailer.send_approval_or_rejection_notification(@leave).deliver
    redirect_to leave_path(@leave), :notice => 'Applicant shall be notified soon. Thanks!'
  end

  private

  def set_leave
    @leave = params[:id].present? ? Leave.find(params[:id]) : Leave.new
  end

  def find_applied_leave
    @leave = Leave.includes(:user).find_by(id: params[:id])
  end

  def check_permission
    @leave = Leave.find_by(id: params[:id])
    unless current_user.id.in? @leave.approval_path.path_chains.pluck(:user_id) << @leave.user_id
      redirect_to leave_tracker_path(current_user), notice: 'Access Denied'
    end
  end

  def leave_params
    params.require(:leave).permit(:approval_path_id, :user_id, :reason, :leave_type, :pending_at, :status,
                                  :start_date, :end_date, :half_day)
  end
end
