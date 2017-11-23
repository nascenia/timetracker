class AddRewardedLeaveAndCommentToLeaveTracker < ActiveRecord::Migration
  def change
    add_column :leave_trackers, :awarded_leave, :integer, default: 0
    add_column :leave_trackers, :note, :text
  end
end
