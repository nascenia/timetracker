class ChangeHalfDayToInteger < ActiveRecord::Migration
  def change
    change_column :leaves, :half_day, :integer
  end
end
