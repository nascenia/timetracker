module LeaveTrackerHelper
  def type_of(leave)
    case leave.leave_type
      when 1
        'Casual'
      when 2
        'Medical'
      when 3
        'Unannounced'
    end
  end
end
