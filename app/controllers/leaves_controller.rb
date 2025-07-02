class LeavesController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin_user!, only: [:award]
  before_action :set_leave, only: [:index, :show, :edit]
  before_action :check_permission, only: [:show, :approve]
  before_action :find_applied_leave, only: [:approve, :reject, :destroy]
  before_action :validate_date, only: [:create]

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
    @leave.status = Leave::PENDING
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
        # emails.shift
        # emails.each do |email|
        #   UserMailer.send_leave_application_notification(@leave, email).deliver
        # end
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

      @approvers = User.where(id: approver_ids, is_active: true).pluck(:name)
      @rejector = User.find_by(id: rejecter_id) if rejecter_id

      current_user_priority = @leave.approval_path.path_chains.find_by(user: current_user).try(:priority)
      @show_actions_to_ttfs = @leave.status == Leave::PENDING && @leave.pending_at == current_user_priority ? true : false
      @show_actions_to_admin = current_user.try(:has_admin_privilege?) && @leave.leave_type != Leave::UNANNOUNCED ? true : false
    else
      @show_actions_to_ttfs = false
      @show_actions_to_admin = false
      @approvers = nil
      @rejector = nil
    end
  end

  def approve
    if current_user.try(:has_admin_privilege?)
      @leave.update_attributes(status: Leave::ACCEPTED, pending_at: 0)
      @leave.user.leave_tracker.update_leave_tracker(@leave)
      @leave.remove_unannounced_for_same_date
      UserMailer.send_approval_or_rejection_notification(@leave).deliver
      UserMailer.send_approval_or_rejection_notification_to_hr(@leave).deliver
    else
      if @leave.pending_at == 1
        if @leave.start_date < Date.today
          @leave.update_attribute(:status, Leave::REJECTED)
          flash[:warning] = 'Leave tracker already updated and you can not approved it now!'
          redirect_to :back and return
        end

        @leave.remove_unannounced_for_same_date

        @leave.update_attributes(status: Leave::ACCEPTED, pending_at: 0)
        @leave.user.leave_tracker.update_leave_tracker(@leave)
        @leave.user.leave_tracker.update_leave_tracker_daily()
        UserMailer.send_approval_or_rejection_notification(@leave).deliver
        UserMailer.send_approval_or_rejection_notification_to_hr(@leave).deliver
      else
        @leave.update_attribute(:pending_at, @leave.pending_at -= 1)
        email = @leave.approval_path.path_chains.find_by(priority: @leave.pending_at).user.email
        UserMailer.send_leave_application_notification(@leave, email).deliver
      end
    end
    redirect_to new_leave_comment_path(@leave), turbolinks: false
  end

  def reject
    if current_user.try(:has_admin_privilege?)
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
      redirect_to leave_tracker_path(@leave.user)
    else
      flash[:warning] = 'Leave was not cancelled'
      redirect_to leave_tracker_path(@leave.user)
    end
  end

  def award
    @leave = Leave.new(leave_params)
    @leave.pending_at = 0
    @leave.leave_type = Leave::AWARDED
    @leave.status = Leave::ACCEPTED
    @leave.user_id = params[:id]

    unless @leave.valid_date?
      flash[:notice]='You can not award leaves for Future dates !'
      redirect_to leave_tracker_path(params[:id]) and return
    end
    if @leave.save
      @leave.user.leave_tracker.update_leave_tracker(@leave)
      flash[:notice] = 'Leave awarded Successfully!'
      redirect_to leave_path(@leave)
    else
      flash[:warning] = 'Something went wrong ! Try again.'
      redirect_to leave_tracker_path(params[:id])
    end
  end

  def special_award
    @leave = Leave.new(leave_params)
    @leave.pending_at = 0
    @leave.leave_type = params[:type]
    @leave.status = Leave::ACCEPTED
    @leave.user_id = params[:id]

    unless @leave.valid_date?
      flash[:alert] = 'End date should be greater or equal to Start date'
      redirect_to leave_tracker_path(params[:id]) and return
    end

    if @leave.save
      @leave.user.leave_tracker.update_leave_tracker(@leave)
      flash[:notice] = 'Special leave awarded Successfully!'
      redirect_to leave_path(@leave)
    else
      flash[:warning] = 'Something went wrong ! Try again.'
      redirect_to leave_tracker_path(params[:id])
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
        unless current_user.try(:has_admin_privilege?)
          redirect_to leave_tracker_path(current_user), alert: 'Access Denied'
        end
      end
    end
  end

  def leave_params
    params.require(:leave).permit(:approval_path_id, :user_id, :reason, :leave_type, :pending_at, :status,
                                  :start_date, :end_date, :half_day, :hour)
  end

  def validate_date
    start_date=params['leave']['start_date']
    end_date=params['leave']['end_date']
    type=params['leave']['leave_type']

    if start_date.nil? || end_date.nil?
      flash[:alert] = 'Start date and End date must be filled.'
      redirect_to new_leave_path and return
    end

    if params['leave']['half_day'] != Leave::FULL_DAY.to_s
      if start_date != end_date
        flash[:alert] = 'Start date and End date should be same for Half day leaves.'
        redirect_to new_leave_path and return
      end
    end
    if Date.parse(start_date) > Date.parse(end_date)
      flash[:alert] = 'End date should be greater or equal to Start date'
      redirect_to new_leave_path and return
    end

    if type == Leave::CASUAL.to_s
      if Date.parse(start_date) < Date.current || Date.parse(end_date) < Date.current
        flash[:alert] = 'Casual leaves can only be applied for future dates.'
        redirect_to new_leave_path and return
      end
    end
  end

end
