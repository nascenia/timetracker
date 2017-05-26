module LeavesHelper

  def get_duration(leave)
    case leave.half_day
      when 0
        'Full Day'
      when 1
        'First Half'
      when 2
        'Second Half'
    end
  end

  def get_status(leave_id)
    status = Leave::LEAVE_STATUSES.select { |status| status.last == leave_id }
    status[0].try(:first)
  end

  def get_type(leave)
    case leave.leave_type
    when Leave::CASUAL
      'Casual'
    when Leave::MEDICAL
      'Medical'
    else
      'Unannounced'
    end
  end

  def has_owned_paths?
    current_user.owned_paths.length > 0 ? true : false
  end

  def leave_balance(leave)
    if leave.user.leave_tracker.present?
      return leave.user.leave_tracker.accrued_vacation_total
    else
      return '-'
    end
  end
end
