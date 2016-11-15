class AddColumnParentIdToAttendance < ActiveRecord::Migration
  def change
    add_column :attendances, :parent_id, :integer
  end
end
