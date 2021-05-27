class CreateTimesheets < ActiveRecord::Migration
  def change
    create_table :timesheets do |t|
      t.date :date
      t.text :description
      t.references :project, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
