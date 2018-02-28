class LeavesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_leave, only: [:index, :show, :edit]
  before_action :check_permission, only: [:show, :approve]
  before_action :find_applied_leave, only: [:approve, :reject, :destroy]
  # before_action :validate_date, only: [:create]

  layout 'leave'

  def index
    if params[:category].present?
      @leaves = Leave.where('leaves.approval_path_id IN (?)', current_user.owned_paths.pluck(:approval_path_id))
                    .where(status: params[:category].to_i).order(created_at: :desc)
    else
      @leaves = Leave.where('leaves.approval_path_id IN (?)', current_user.owned_paths.pluck(:approval_path_id))
                    .pending_leaves.order(created_at: :desc)
    end
  end

  def new
    @leave = Leave.new
    user = User.find(current_user.id)
    if user.leave_tracker.accrued_vacation_balance < 8 &&
        user.leave_tracker.accrued_medical_balance < 8
      flash[:warning] = 'You are running low on both Casual and Medical leave'
    elsif user.leave_tracker.accrued_medical_balance < 8
      flash[:warning] = 'You are running low on Medical leave'
    elsif user.leave_tracker.accrued_vacation_balance < 8
      flash[:warning] = 'You are running low on Casual leave'
    end
    unless current_user.approval_path.present? && current_user.weekend.present? && current_user.holiday_scheme.present?
      flash[:alert] = 'You have to be assigned to a leave path, weekend scheme and holiday scheme to apply leave. Please contact with HR'
      flash[:warning] = nil
      flash[:notice] = nil
      @user = current_user
      @leave_tracker = user.leave_tracker
      render 'leave_tracker/show' and return
    end
  end

  def create
    @leave = Leave.new(leave_params)
    @leave.user_id = current_user.id
    approval_users = @leave.approval_path.path_chains.order(priority: :desc).map(&:user_id)
    emails = []
    approval_users.each do |approval_user|
      email = User.find_by(id: approval_user).email
      emails << email
    end
    email = emails[0]
    if @leave.save
      if UserMailer.send_leave_application_notification(@leave, emails[0]).deliver
        emails.shift
        emails.each do |email|
          UserMailer.send_leave_application_notification(@leave, email).deliver
        end
        redirect_to leave_path(@leave), notice: 'Your TTF will be notified soon. Thanks!'
      else
        redirect_to leave_path(@leave), alert: 'Sorry something went wrong to send mail, please contact with your TTF'
      end
    else
      render :new
    end
  end

  def show
    if @leave.approval_path.present?
      approver_ids = @leave.approval_path.path_chains.where('priority > ?', @leave.pending_at).pluck(:user_id)
      rejecter = @leave.approval_path.path_chains.find_by(priority: @leave.pending_at)

      if @leave.status == Leave::REJECTED && rejecter.present?
        rejecter_id = @leave.approval_path.path_chains.find_by(priority: @leave.pending_at).user_id
        rejecter_id = false
      end

      @approvers = User.where(id: approver_ids).pluck(:name)
      @rejector = User.find_by(id: rejecter_id) if rejecter_id

      current_user_priority = @leave.approval_path.path_chains.find_by(user: current_user).try(:priority)
      @show_actions_to_ttfs = @leave.status == Leave::PENDING && @leave.pending_at == current_user_priority ? true : false
      @show_actions_to_admin = current_user.try(:is_admin?) && @leave.leave_type != Leave::UNANNOUNCED ? true : false
    else
      flash[:alert] = 'Something went wrong. Please try again'
      redirect_to :back
    end
  end

  def approve
    if current_user.try(:is_admin?)
      @leave.update_attributes(status: Leave::ACCEPTED, pending_at: 0)
      @leave.user.leave_tracker.update_leave_tracker(@leave)
      UserMailer.send_approval_or_rejection_notification(@leave).deliver
      UserMailer.send_approval_or_rejection_notification_to_hr(@leave).deliver
    else
      if @leave.pending_at == 1
        leaves = 0
        if @leave.start_date < Date.today
          @leave.update_attribute(:status, Leave::REJECTED)
          flash[:warning] = 'Leave tracker already updated and you can not approved it now!'
          redirect_to :back and return
        elsif @leave.half_day == 0
          leaves_total = @leave.user.leaves.where("leave_type =? AND start_date =? ", 3, @leave.start_date)
        else
          leaves_total = @leave.user.leaves.where("leave_type =? AND start_date =? ", @leave.half_day , @leave.start_date)
        end
        leaves = leaves_total.count
        hours_leaves = leaves  * 4
        @leave.user.leave_tracker.update_attribute(:consumed_vacation, @leave.user.leave_tracker.consumed_vacation - hours_leaves)
        @leave.update_attributes(status: Leave::ACCEPTED, pending_at: 0)
        @leave.user.leave_tracker.update_leave_tracker(@leave)
        UserMailer.send_approval_or_rejection_notification(@leave).deliver
        UserMailer.send_approval_or_rejection_notification_to_hr(@leave).deliver
        leaves_total.destroy_all
      else
        @leave.update_attribute(:pending_at, @leave.pending_at -= 1)
        email = @leave.approval_path.path_chains.find_by(priority: @leave.pending_at).user.email
        UserMailer.send_leave_application_notification(@leave, email).deliver
      end
    end
    redirect_to new_leave_comment_path(@leave), turbolinks: false
  end

  def reject
    if current_user.try(:is_admin?)
      @leave.user.leave_tracker.revert_leave_tracker(@leave) if @leave.status == Leave::ACCEPTED
      @leave.update_attribute(:status, Leave::REJECTED)
      UserMailer.send_approval_or_rejection_notification(@leave).deliver
      UserMailer.send_approval_or_rejection_notification_to_hr(@leave).deliver
    else
      @leave.update_attribute(:status, Leave::REJECTED)
      UserMailer.send_approval_or_rejection_notification(@leave).deliver
      UserMailer.send_approval_or_rejection_notification_to_hr(@leave).deliver
    end
    redirect_to new_leave_comment_path(@leave), turbolinks: false
  end

  def destroy
    if @leave.destroy
      @leave.user.leave_tracker.revert_leave_tracker(@leave) if @leave.status == Leave::ACCEPTED
      flash[:notice] = 'Leave Cancelled Successfully'
      redirect_to leave_tracker_path(current_user)
    else
      flash[:warning] = 'Leave was not cancelled'
      redirect_to leave_tracker_path(current_user)
    end
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
    if @leave.approval_path
      unless current_user.id.in? @leave.approval_path.path_chains.pluck(:user_id) << @leave.user_id
        unless current_user.try(:is_admin?)
          redirect_to leave_tracker_path(current_user), alert: 'Access Denied'
        end
      end
    end
  end

  def leave_params
    params.require(:leave).permit(:approval_path_id, :user_id, :reason, :leave_type, :pending_at, :status,
                                  :start_date, :end_date, :half_day)
  end

  def validate_date
    if params['leave']['leave_type'] == '1'
      unless Date.parse(params['leave']['start_date']).future?
        flash[:alert] = 'Casual leaves can only be applied for future dates'
        redirect_to new_leave_path
      end
    end
  end
end
