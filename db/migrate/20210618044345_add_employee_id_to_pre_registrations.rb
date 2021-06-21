class AddEmployeeIdToPreRegistrations < ActiveRecord::Migration
  def change
    add_column :pre_registrations, :employee_id, :string, limit: 16
  end
end
