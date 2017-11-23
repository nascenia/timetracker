class AddRewardedLeaveAndCommentToLeaveTracker < ActiveRecord::Migration
  def change
    add_column :leave_trackers, :rewarded_leave, :integer, default: 0
    add_column :leave_trackers, :note, :string
  end
end
