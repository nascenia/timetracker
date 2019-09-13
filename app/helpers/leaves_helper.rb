module LeavesHelper

  def get_duration(leave)
    return leave.hour if leave.leave_type == Leave::AWARDED
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

    if status[0].try(:first) == 'Rollbacked'
      'Rolled back due to resignation'
    else
      status[0].try(:first)
    end
  end

  def get_type(leave)
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

  def has_co_worker?
    has_owned_paths? || current_user.role == User::SUPER_TTF || current_user.role == User::TTF
  end

  def show_pending_leave?(leave)
    if leave.approval_path.present?
      current_user_priority = leave.approval_path.path_chains.find_by(user: current_user).try(:priority)
      leave.pending_at == current_user_priority ? true : false
    else
      false
    end
  end
end
