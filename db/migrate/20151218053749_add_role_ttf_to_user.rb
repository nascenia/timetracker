class AddRoleTtfToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :role, :integer
    add_column :users, :ttf_id, :integer
    add_column :users, :sttf_id, :integer
  end

  def self.down
    remove_column :users, :role
    remove_column :users, :ttf_id
    remove_column :users, :sttf_id
  end
end
