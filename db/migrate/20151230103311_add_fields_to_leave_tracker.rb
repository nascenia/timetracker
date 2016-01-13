class AddFieldsToLeaveTracker < ActiveRecord::Migration
  def self.up
    add_column :leave_trackers, :accrued_vacation_this_year, :integer, :default => 0
    add_column :leave_trackers, :accrued_medical_this_year, :integer, :default => 0
    add_column :leave_trackers, :accrued_vacation_total, :integer, :default => 0
    add_column :leave_trackers, :accrued_medical_total, :integer, :default => 0
    rename_column :leave_trackers, :accrued_casual_leave, :accrued_vacation_balance
    rename_column :leave_trackers, :accrued_medical_leave, :accrued_medical_balance
    rename_column :leave_trackers, :carried_forward_casual, :carried_forward_vacation
    rename_column :leave_trackers, :consumed_casual_leave, :consumed_vacation
    rename_column :leave_trackers, :consumed_medical_leave, :consumed_medical
    remove_column :leave_trackers, :status
  end

  def self.down
    remove_column :leave_trackers, :accrued_vacation_in_this_year
    remove_column :leave_trackers, :accrued_medical_in_this_year
    remove_column :leave_trackers, :accrued_vacation_in_total
    remove_column :leave_trackers, :accrued_medical_in_total
  end

end
