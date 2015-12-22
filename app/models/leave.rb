class Leave < ActiveRecord::Base
  belongs_to :user

  LEAVE_TYPES = [['Casual', 1], ['Medical', 2]]
end
