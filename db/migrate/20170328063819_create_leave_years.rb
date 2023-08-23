class CreateLeaveYears < ActiveRecord::Migration[7.0]
  def change
    create_table :leave_years do |t|
      t.string 'year'
      t.boolean 'present'
      t.timestamps
    end
  end
end
