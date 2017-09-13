class SuperAdminLeavesController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :find_leave

  layout 'leave'

  def index
    if params[:category].present?
      case params[:category].to_i
        when 0
          @leaves = Leave.all.order(start_date: :desc)
        when Leave::ACCEPTED
          @leaves = Leave.accepted_leaves.order(start_date: :desc)
        when Leave::REJECTED
          @leaves = Leave.rejected_leaves.order(start_date: :desc)
        when Leave::PENDING
          @leaves = Leave.pending_leaves.order(start_date: :desc)
      end
    else
      @leaves = Leave.all.order(start_date: :desc)
    end

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
    else
      Leave::UNANNOUNCED
    end
  end
end
