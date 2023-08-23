class AddApprovalPathIdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_reference :users, :approval_path, foreign_key: true
  end
end
