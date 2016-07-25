class AddIndexToTables < ActiveRecord::Migration
  def change
    add_index :attendances, :user_id
    add_index :leaves, :user_id
    add_index :leave_trackers, :user_id
  end
end
