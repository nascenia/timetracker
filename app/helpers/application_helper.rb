module ApplicationHelper
  def copyright_year
    Time.zone.now.year
  end

  def is_late_attendance? check_in_time
    Time.at(check_in_time).strftime('%H:%M') > Time.at(Time.parse(Attendance::USUAL_OFFICE_TIME)).strftime('%H:%M')
  end

  def is_checked_in? attendance

    check_in_button = 'btn-success'

    unless attendance.nil?
      check_in_button = attendance.in_time.present? && attendance.out_time.nil? ? 'btn-default disabled' : 'btn-success'
    end

    return check_in_button
  end

  def is_checked_out? attendance
    unless attendance.nil?
      attendance.out_time.present? ? 'btn-default disabled' : 'btn-danger'
    end
  end

  def get_humanize_date date
    date.present? ? date.strftime('%B %d, %Y') : '-'
  end

  def get_formatted_date date
    date.present? ? date.strftime('%d-%m-%Y') : '-'
  end

  def get_formatted_time time
     time.present? ? Time.at(time).utc.strftime('%I:%M %p') : '-'
  end
end
