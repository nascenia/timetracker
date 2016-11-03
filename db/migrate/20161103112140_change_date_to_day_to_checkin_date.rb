class ChangeDateToDayToCheckinDate < ActiveRecord::Migration
  def change
    rename_column :attendances, :datetoday, :checkin_date
  end
end
