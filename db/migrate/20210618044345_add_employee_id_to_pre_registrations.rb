class AddEmployeeIdToPreRegistrations < ActiveRecord::Migration[7.0]
  def change
    add_column :pre_registrations, :employee_id, :string, limit: 16
  end
end
