class LeavesController < ApplicationController
  layout 'leave'

  before_action :set_leave, only: [:index, :show, :edit, :update, :destroy]

  def new
    @leave = Leave.new
  end

  def create
    @leave = Leave.new(leave_params)
    @leave.user_id = current_user.id

    if @leave.save
      UserMailer.send_leave_application_notification(current_user, @leave).deliver
      redirect_to @leave, :notice => 'Your TTF will be notified soon. Thanks!'
    else
      render :new
    end
  end

  def show
    respond_to do |format|
      format.html
    end
  end

  def approve_or_reject_leave
    @leave = Leave.find params[:leafe_id]

    respond_to do |format|
      format.html
    end
  end

  def approve
    @leave = Leave.find params[:leafe_id]
    @leave.update_attribute(:status, Leave::ACCEPTED)

    UserMailer.send_approval_or_rejection_notification(@leave)
    redirect_to leafe_approve_or_reject_leave_path(@leave), :notice => 'Applicant shall be notified soon. Thanks!'
  end

  def reject
    @leave = Leave.find params[:leafe_id]
    @leave.update_attribute(:status, Leave::REJECTED)

    UserMailer.send_approval_or_rejection_notification(@leave)
    redirect_to leafe_approve_or_reject_leave_path(@leave), :alert => 'Applicant shall be notified soon. Thanks!'
  end

  private

    def set_leave
      @leave = params[:id].present? ? Leave.find(params[:id]) : Leave.new
    end

    def leave_params
      params.require(:leave).permit(:user_id, :reason, :leave_type, :status, :start_date,
                                    :end_date, :half_day)
    end
end

