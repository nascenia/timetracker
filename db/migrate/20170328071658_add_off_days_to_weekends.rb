class AddOffDaysToWeekends < ActiveRecord::Migration[7.0]
  def change
    add_column :weekends, :off_days, :integer
  end
end
