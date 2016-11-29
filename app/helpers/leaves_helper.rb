module LeavesHelper

  def get_status leave_id
    status = Leave::LEAVE_STATUSES.select { |status| status.last == leave_id }
    status[0].first
  end

  def get_type leave
    leave.leave_type == Leave::CASUAL ? 'Casual' : 'Medical'
  end

  def leave_balance leave
    if leave.user.leave_tracker.present?
      return leave.user.leave_tracker.accrued_vacation_total
    else
      return '-'
    end
  end
end
