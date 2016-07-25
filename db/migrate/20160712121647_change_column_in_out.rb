class ChangeColumnInOut < ActiveRecord::Migration
  def change
    rename_column :attendances, :in, :in_time
    rename_column :attendances, :out, :out_time
  end
end
