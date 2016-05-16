class AddCommencedDateToLeaveTracker < ActiveRecord::Migration
  def self.up
    add_column :leave_trackers, :commenced_date, :datetime
  end

  def self.down
    remove_column :leave_trackers, :commenced_date
  end
end
