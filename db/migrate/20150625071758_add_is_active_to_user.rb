class AddIsActiveToUser < ActiveRecord::Migration[7.0]
  def self.up
    add_column :users, :is_active, :boolean, :default => true
  end

  def self.down
    remove_column :users, :is_active
  end
end
