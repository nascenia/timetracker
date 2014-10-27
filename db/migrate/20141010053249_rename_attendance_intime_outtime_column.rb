class RenameAttendanceIntimeOuttimeColumn < ActiveRecord::Migration
  def self.up
    rename_column :attendances, :intime, :in
    rename_column :attendances, :outtime, :out
  end
end
