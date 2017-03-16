class Leave < ActiveRecord::Base
  belongs_to :approval_path
  belongs_to :user
  belongs_to :leave_tracker

  validates :pending_at, presence: true

  CASUAL = 1
  MEDICAL = 2
  UNANNOUNCED = 3

  LEAVE_TYPES = [
      ['Casual Leave', CASUAL],
      ['Medical Leave', MEDICAL]
  ]

  ACCEPTED = 1
  REJECTED = 2
  PENDING = 3

  HOURS_FOR_ONE_DAY = 8
  HOURS_FOR_HALF_DAY = HOURS_FOR_ONE_DAY / 2

  LEAVE_STATUSES = [
      ['Approved', ACCEPTED],
      ['Rejected', REJECTED],
      ['Pending', PENDING]
  ]

  def update_leave_tracker
    consumed_casual_leave = self.user.leave_tracker.consumed_vacation.present? ? self.user.leave_tracker.consumed_vacation : 0
    consumed_medical_leave = self.user.leave_tracker.consumed_medical.present? ? self.user.leave_tracker.consumed_medical : 0

    if self.end_date.present?
      total_hours = (1 + (self.end_date - self.start_date).to_i) * HOURS_FOR_ONE_DAY
    else
      total_hours = HOURS_FOR_ONE_DAY
    end

    if self.half_day
      total_hours_to_be_consumed = total_hours - HOURS_FOR_HALF_DAY
    else
      total_hours_to_be_consumed = total_hours
    end

    if self.leave_type == CASUAL || self.leave_type == UNANNOUNCED
      consumed_casual_leave_balance = consumed_casual_leave.to_i + total_hours_to_be_consumed
      self.user.leave_tracker.update_attributes(:consumed_vacation => consumed_casual_leave_balance)
    else
      consumed_medical_leave_balance = consumed_medical_leave + total_hours_to_be_consumed
      self.user.leave_tracker.update_attributes(:consumed_medical => consumed_medical_leave_balance)
    end
  end

  def self.get_pending_leaves(current_user)
    path_priority_list = current_user.owned_paths.pluck(:approval_path_id, :priority)

    leaves = Leave.none

    path_priority_list.each do |path_priority|
      leaves += Leave.where(approval_path_id: path_priority[0], pending_at: path_priority[1])
    end
    leaves
  end

  def is_pending?
    self.status == PENDING
  end

  def is_accepted?
    self.status == ACCEPTED
  end

  def is_rejected?
    self.status == REJECTED
  end
end
