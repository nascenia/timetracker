class RemoveIsFirstEntryFromAttendances < ActiveRecord::Migration[7.0]
  def change
    remove_column :attendances, :is_first_entry
  end
end
