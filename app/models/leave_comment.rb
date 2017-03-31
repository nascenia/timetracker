class LeaveComment < ActiveRecord::Base
  belongs_to :leave
  belongs_to :user

  validates :comment, presence: true
end
