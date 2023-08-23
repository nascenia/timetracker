class AddColumnLeaveApprovalPathIdToPreRegistrations < ActiveRecord::Migration[7.0]
  def change
    add_column :pre_registrations, :leave_approval_path_id, :integer
  end
end
