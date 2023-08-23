class AddMoreDetailsToTimesheets < ActiveRecord::Migration[7.0]
  def change
    add_column :timesheets, :task, :text
    add_column :timesheets, :ticket_number, :string
    add_column :timesheets, :ticket_link, :text
    add_column :timesheets, :hours, :integer
    add_column :timesheets, :minutes, :integer
  end
end
