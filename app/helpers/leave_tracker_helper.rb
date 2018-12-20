module LeaveTrackerHelper
  def type_of(leave)
    case leave.leave_type
      when Leave::CASUAL
        'Casual'
      when Leave::MEDICAL
        'Medical'
      when Leave::AWARDED
        'Awarded'
      else
        'Unannounced'
    end
  end
end
