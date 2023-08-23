class ChangeColumnInOut < ActiveRecord::Migration[7.0]
  def change
    rename_column :attendances, :in, :in_time
    rename_column :attendances, :out, :out_time
  end
end
