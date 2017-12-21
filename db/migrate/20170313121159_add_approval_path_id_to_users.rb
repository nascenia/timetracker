class AddApprovalPathIdToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :approval_path, foreign_key: true
  end
end
