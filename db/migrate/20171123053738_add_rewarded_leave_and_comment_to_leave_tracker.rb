class AddRewardedLeaveAndCommentToLeaveTracker < ActiveRecord::Migration[7.0]
  def change
    add_column :leave_trackers, :awarded_leave, :integer, default: 0
    add_column :leave_trackers, :note, :text
  end
end
