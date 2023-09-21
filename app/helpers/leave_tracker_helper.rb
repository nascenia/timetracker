module LeaveTrackerHelper
  def type_of(leave)
    # p Leave::LEAVE_TYPES[leave.leave_type]
    case leave.leave_type
      when Leave::CASUAL
        'Casual'
      when Leave::MEDICAL
        'Medical'
      when Leave::AWARDED
        'Awarded'
      when Leave::PATERNITY
        'Paternity'
      when Leave::MATERNITY
        'Maternity'
      else
        'Unannounced'
    end
  end
end
