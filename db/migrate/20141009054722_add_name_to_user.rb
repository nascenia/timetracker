class AddNameToUser < ActiveRecord::Migration[7.0]
  def self.up
    add_column :users, :name, :string
  end

  def self.down
    remove_column :users, :name
  end
end
