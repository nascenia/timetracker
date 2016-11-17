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
end
