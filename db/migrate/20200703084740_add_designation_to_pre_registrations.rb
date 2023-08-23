class AddDesignationToPreRegistrations < ActiveRecord::Migration[7.0]
  def change
    add_column :pre_registrations, :designation, :string
  end
end
