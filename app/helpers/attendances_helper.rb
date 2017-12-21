module AttendancesHelper

  def get_month_name month
    Attendance::MONTHS[month.to_i - 1].last
  end

  def get_formatted_months
    Attendance::MONTHS.collect { |m| [m.last, m.first] }
  end

  def get_years
    CONFIG['year_range']['start'] .. CONFIG['year_range']['end']
  end

  def get_daily_total_hours attendance

    total_hours ||= attendance.total_hours.nil? ? 0 : attendance.total_hours

    attendance.children.each do |attend|
      total_hours = total_hours + (attend.total_hours.nil? ? 0 : attend.total_hours)
    end if attendance.has_multiple_checkin?

    total_hours.round(3)
    (total_hours.to_i).to_s + ' Hours ' + (((total_hours % 1)* 60).round(0)).to_s + ' Minutes '
  end

  def get_attendance_total_hour attendance
    attendance.total_hours.present? ? attendance.total_hours : '-'
  end
end
