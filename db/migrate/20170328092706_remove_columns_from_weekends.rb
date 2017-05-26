class RemoveColumnsFromWeekends < ActiveRecord::Migration
  def change
    remove_column :weekends, :saturday, :string
    remove_column :weekends, :sunday, :string
    remove_column :weekends, :monday, :string
    remove_column :weekends, :tuesday, :string
    remove_column :weekends, :wednesday, :string
    remove_column :weekends, :thursday, :string
    remove_column :weekends, :friday, :string
  end
end
