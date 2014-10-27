class AddTotalHourToAttendance < ActiveRecord::Migration
  def self.up
    add_column :attendances, :total_hours, :float
  end

  def self.down
    remove_column :attendances, :total_hours
  end
end
