class RenameAttendanceIntimeOuttimeColumn < ActiveRecord::Migration[7.0]
  def self.up
    rename_column :attendances, :intime, :in
    rename_column :attendances, :outtime, :out
  end
end
