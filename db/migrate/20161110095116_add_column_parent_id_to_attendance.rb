class AddColumnParentIdToAttendance < ActiveRecord::Migration[7.0]
  def change
    add_column :attendances, :parent_id, :integer
  end
end
