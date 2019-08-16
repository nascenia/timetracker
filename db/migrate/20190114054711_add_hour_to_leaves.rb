class AddHourToLeaves < ActiveRecord::Migration
  def change
    add_column :leaves, :hour, :integer
  end
end
