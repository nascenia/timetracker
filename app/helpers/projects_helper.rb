module ProjectsHelper
  def calculate_hours(hours, minutes)
    total_hour = hours.to_f + (minutes.to_f / 60.0)

    return total_hour.to_s
  end
end
