module ApplicationHelper

  def is_late_attendance? check_in_time
    Time.at(check_in_time).strftime('%H:%M') > Time.at(Time.parse(Attendance::USUAL_OFFICE_TIME)).strftime('%H:%M')
  end

  def is_checked_in? attendance
    unless attendance.nil?
      attendance.in_time.present? && attendance.out_time.nil? ? 'disabled' : ''
    end
  end

  def is_checked_out? attendance
    unless attendance.nil?
      attendance.out_time.present? ? 'disabled' : ''
    end
  end
end
