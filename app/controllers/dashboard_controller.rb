class DashboardController < ApplicationController
	before_action :restrict_access, only: [:create, :update]
  before_action :authenticate_user!

  layout 'timetracker'

  def index
    flash[:alert] = nil

    if current_user.all_information_provided?
      @attendance = current_user.attendances.where(checkin_date: Time.now.strftime('%Y-%m-%d')).last
      @attendances = Attendance.daily_attendance_summary(Date.today).includes(:children)
      @attendance_summary = current_user.attendances.monthly_attendance_summary(Date.today.at_beginning_of_month,
                                                                        Date.today).includes(:children)
      @all_approved_leaves = Leave.get_users_on_leave_today

      respond_to do |format|
        format.html
      end
    else
      flash[:warning] = 'Please fill up all your details to checking in.'
      redirect_to edit_user_registration_path
    end
  end
end
