class ChangeFirstEntryToAttendence < ActiveRecord::Migration[7.0]
  def change
    rename_column :attendances, :first_entry, :is_first_entry
  end
end
