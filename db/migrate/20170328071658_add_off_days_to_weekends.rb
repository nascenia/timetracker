class AddOffDaysToWeekends < ActiveRecord::Migration
  def change
    add_column :weekends, :off_days, :integer
  end
end
