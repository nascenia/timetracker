module LeavesHelper

  def get_status leave_id
    status = Leave::LEAVE_STATUSES.select { |status| status.last == leave_id }
    status[0].first
  end
end
