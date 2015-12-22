class AddFieldsToLeave < ActiveRecord::Migration
  def self.up
    add_column :leaves, :start_date, :date
    add_column :leaves, :end_date, :date
    add_column :leaves, :half_day, :boolean
  end

  def self.down
    remove_column :leaves, :start_date
    remove_column :leaves, :end_date
    remove_column :leaves, :half_day
  end
end
