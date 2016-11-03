class ChangeFirstEntryToAttendence < ActiveRecord::Migration
  def change
    rename_column :attendances, :first_entry, :is_first_entry
  end
end
