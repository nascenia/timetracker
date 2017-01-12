class RemoveIsFirstEntryFromAttendances < ActiveRecord::Migration
  def change
    remove_column :attendances, :is_first_entry
  end
end
