module LeavesHelper

  def get_status leave_id
    status = Leave::LEAVE_STATUSES.select { |status| status.last == leave_id }
    status[0].try(:first)
  end

  def get_type leave
    leave.leave_type == Leave::CASUAL ? 'Casual' : 'Medical'
  end

  def has_owned_paths?
    current_user.owned_paths.length > 0 ? true : false
  end

  def leave_balance leave
    if leave.user.leave_tracker.present?
      return leave.user.leave_tracker.accrued_vacation_total
    else
      return '-'
    end
  end
end
