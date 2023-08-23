class AddHourToLeaves < ActiveRecord::Migration[7.0]
  def change
    add_column :leaves, :hour, :integer
  end
end
