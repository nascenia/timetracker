module ProjectsHelper
  def calculate_hours(hours, minutes)
    total_hour = hours.to_f + (minutes.to_f / 60.0)

    return total_hour.to_s
  end

  def total_working_hours(timesheets)
    total_minutes = timesheets.inject(0) {|sum, h| sum + h[:working_minutes]}

    return total_minutes / 60
  end

  def user_timesheet_summary(timesheets)

    projects = []
    total_minutes = timesheets.inject(0) {|sum, h| sum + h[:working_minutes]}

    timesheets.each do |project|
      next if project[:working_minutes].zero?
      
      str = project[:project_name]

      if total_minutes > 0 
        str += " #{(100.0 * (project[:working_minutes].to_f / total_minutes.to_f)).round(2)}%"
      else
        str += " 0.0%"
      end

      str += " (#{project[:working_minutes] / 60})"

      projects << str
    end

    projects.join(" | ")
  end
end
