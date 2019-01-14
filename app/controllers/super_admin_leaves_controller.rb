class SuperAdminLeavesController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :find_leave

  layout 'leave'

  def index
    # @leaves = Leave.page(params[:page]).includes(:user)
    @leaves = Leave.not_rollbacked_leaves.includes(:user)
    @leaves = @leaves.leaves_by_status(params[:status]) if params[:status].present?
    @leaves = @leaves.leaves_by_type(params[:type]) if params[:type].present?

    if params[:time].present?
      @leaves = @leaves.leaves_by_month(Date.current.strftime('%m')).leaves_by_year(Date.current.strftime('%Y')) if params[:time] == '1'
      @leaves = @leaves.leaves_by_year(Date.current.strftime('%Y')) if params[:time] == '2'
      @leaves = @leaves.leaves_by_month((Date.current-1.month).strftime('%m')).leaves_by_year((Date.current-1.month).strftime('%Y')) if params[:time] == '3'
      @leaves = @leaves.leaves_by_year((Date.current-1.year).strftime('%Y')) if params[:time] == '4'
    end
    if params[:start_date].present? && params[:end_date].present?
      @leaves = @leaves.leaves_in_between(params[:start_date], params[:end_date])
    end
    @leaves = @leaves.order(start_date: :desc)
  end

  def change_type
    type = get_type(params[:type])

    if @leave.status == Leave::ACCEPTED
      @leave.revert_leave_tracker
      @leave.update_attribute(:leave_type, type)
      @leave.update_leave_tracker
    else
      @leave.update_attribute(:leave_type, type)
    end
    UserMailer.send_leave_type_change_notification(@leave).deliver
    redirect_to leave_path(@leave)
  end

  private

  def find_leave
    @leave = Leave.find_by(id: params[:id])
  end

  def get_type(type)
    case type
    when 'Casual'
      Leave::CASUAL
    when 'Medical'
      Leave::MEDICAL
    when 'Awarded'
      Leave::AWARDED
    else
      Leave::UNANNOUNCED
    end
  end
end
