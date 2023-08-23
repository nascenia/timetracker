class AddIndexToTables < ActiveRecord::Migration[7.0]
  def change
    add_index :attendances, :user_id
    add_index :leaves, :user_id
    add_index :leave_trackers, :user_id
  end
end
