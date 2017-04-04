class ModifyLeaveComments < ActiveRecord::Migration
  def change
    rename_table :leave_comments, :comments
    rename_column :comments, :comment, :body
    change_column :comments, :body, :text
  end
end
