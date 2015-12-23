class Leave < ActiveRecord::Base
  belongs_to :user

  CASUAL = 1
  MEDICAL = 2

  LEAVE_TYPES = [['Casual Leave', CASUAL], ['Medical Leave', MEDICAL]]

  ACCEPTED = 1
  REJECTED = 2
  PENDING = 3

  LEAVE_STATUSES = [['Approved', ACCEPTED], ['Rejected', REJECTED], ['Pending', PENDING]]
end
