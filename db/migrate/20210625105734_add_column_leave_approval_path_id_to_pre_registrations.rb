class AddColumnLeaveApprovalPathIdToPreRegistrations < ActiveRecord::Migration
  def change
    add_column :pre_registrations, :leave_approval_path_id, :integer
  end
end
