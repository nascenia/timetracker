class AddDesignationToPreRegistrations < ActiveRecord::Migration
  def change
    add_column :pre_registrations, :designation, :string
  end
end
