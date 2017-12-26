class ModifyApprovalPath < ActiveRecord::Migration
  def change
    remove_column :approval_paths, :user_id
    remove_column :approval_paths, :active
    add_column :approval_paths, :name, :string, null: false
  end
end
