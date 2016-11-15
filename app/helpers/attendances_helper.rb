module AttendancesHelper

  def monthly_total_hours monthly_attendance

    if monthly_attendance.nil?
      return
    end

    total_hours = 0.0

    monthly_attendance.each do |attendance|

      total_hours = total_hours + (attendance.total_hours.nil? ? 0 : attendance.total_hours)

      attendance.children.each do |child|
        total_hours = total_hours + (child.total_hours.nil? ? 0 : child.total_hours)
      end
    end

    total_hours.round(3)
  end

  def monthly_average_hours total_hours, total_attendance

    average_hours = total_attendance > 0 ? total_hours / total_attendance : 0
    average_hours.round(3)
  end

  def monthly_average_check_in_time monthly_attendance
    if monthly_attendance.size == 0
      return 0.0
    end

    total_days = monthly_attendance.size

    average_minutes = monthly_attendance.map do |attendence|
      hour, minutes = attendence.in_time.strftime('%H:%M:%S').split(':')
      total_minutes = hour.to_i * 60 + minutes.to_i
    end.inject(:+) / total_days

    average_time = '%s:%s' % average_minutes.divmod(60).map(&:to_i)
    Time.parse(average_time).strftime('%I:%M %p')
  end
end
