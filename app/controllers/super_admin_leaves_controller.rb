class SuperAdminLeavesController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :find_leave

  layout 'leave'

  def index
    @users = User.active.map{|u| [u.name, u.id]}
    @pagy, @leaves = pagy(Leave.search(params[:leave]))
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
    when 'Paternity'
      Leave::PATERNITY
    when 'Maternity'
      Leave::MATERNITY
    else
      Leave::UNANNOUNCED
    end
  end
end
