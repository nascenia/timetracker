class AddApprovalPathIdToLeaves < ActiveRecord::Migration
  def change
    add_reference :leaves, :approval_path, index: true
  end
end
