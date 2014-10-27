class CreateAttendances < ActiveRecord::Migration
  def change
    create_table :attendances do |t|
      t.integer :user_id
      t.date :datetoday
      t.time :intime
      t.time :outtime

      t.timestamps
    end
  end
end
