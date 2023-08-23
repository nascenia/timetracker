class AddApprovalPathIdToLeaves < ActiveRecord::Migration[7.0]
  def change
    add_reference :leaves, :approval_path, index: true
  end
end
