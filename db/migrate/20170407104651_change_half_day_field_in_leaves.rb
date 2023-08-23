class ChangeHalfDayFieldInLeaves < ActiveRecord::Migration[7.0]
  def up
    # If there is a leave entry with half_day value as nil, the migration doesn't run, that's why
    # we have to modify existing half_day value to 0 where it is nil
    update 'UPDATE leaves SET leaves.half_day = 0 where leaves.half_day IS NULL'

    change_column :leaves, :half_day, :integer, default: 0, null: false
  end

  def down
    change_column :leaves, :half_day, :integer
  end
end
