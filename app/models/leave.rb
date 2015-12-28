class Leave < ActiveRecord::Base
  belongs_to :user
  has_one :leave_tracker, :foreign_key => :user_id

  CASUAL = 1
  MEDICAL = 2

  LEAVE_TYPES = [['Casual Leave', CASUAL], ['Medical Leave', MEDICAL]]

  ACCEPTED = 1
  REJECTED = 2
  PENDING = 3

  HOURS_FOR_ONE_DAY = 8
  HOURS_FOR_HALF_DAY = 4

  LEAVE_STATUSES = [['Approved', ACCEPTED], ['Rejected', REJECTED], ['Pending', PENDING]]

  def update_leave_tracker
    accrued_casual_leave = self.leave_tracker.accrued_casual_leave
    accrued_medical_leave = self.leave_tracker.accrued_medical_leave
    consumed_casual_leave = self.leave_tracker.consumed_casual_leave
    consumed_medical_leave = self.leave_tracker.consumed_medical_leave

    if self.end_date.present?
      total_hours = (1+(self.end_date - self.start_date).to_i) * HOURS_FOR_ONE_DAY
    else
      total_hours = HOURS_FOR_ONE_DAY
    end

    if self.half_day
      total_hours_to_be_sonsumed = total_hours - HOURS_FOR_HALF_DAY
    end


    if self.leave_type == CASUAL
      accrued_casual_leave_balance = accrued_casual_leave - total_hours_to_be_sonsumed
      consumed_casual_leave_balance = consumed_casual_leave + total_hours_to_be_sonsumed
      self.update_attributes(:accrued_casual_leave => accrued_casual_leave_balance,
                             :consumed_casual_leave => consumed_casual_leave_balance)
    else
      accrued_medical_leave_balance = accrued_medical_leave - total_hours_to_be_sonsumed
      consumed_medical_leave_balance = consumed_medical_leave + total_hours_to_be_sonsumed

      self.update_attributes(:accrued_medical_leave => accrued_medical_leave_balance,
                             :consumed_medical_leave => consumed_medical_leave_balance)
    end
  end
end
