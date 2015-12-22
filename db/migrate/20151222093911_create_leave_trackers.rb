class CreateLeaveTrackers < ActiveRecord::Migration
  def change
    create_table :leave_trackers do |t|
      t.integer :user_id
      t.integer :yearly_casual_leave
      t.integer :yearly_medical_leave
      t.integer :carried_forward_casual
      t.integer :carried_forward_medical
      t.integer :accrued_casual_leave
      t.integer :accrued_medical_leave
      t.integer :consumed_medical_leave
      t.integer :consumed_casual_leave
      t.integer :status

      t.timestamps
    end
  end
end
