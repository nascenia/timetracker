class AddFirstEntryToAttendance < ActiveRecord::Migration
  def self.up
    add_column :attendances, :first_entry, :boolean, :default => false
  end

  def self.down
    remove_column :attendances, :first_entry
  end
end
