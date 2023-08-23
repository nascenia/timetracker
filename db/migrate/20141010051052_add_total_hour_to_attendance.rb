class AddTotalHourToAttendance < ActiveRecord::Migration[7.0]
  def self.up
    add_column :attendances, :total_hours, :float
  end

  def self.down
    remove_column :attendances, :total_hours
  end
end
