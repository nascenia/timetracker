class ChangeDateToDayToCheckinDate < ActiveRecord::Migration[7.0]
  def change
    rename_column :attendances, :datetoday, :checkin_date
  end
end
