class CreateHolidaySchemes < ActiveRecord::Migration
  def change
    create_table :holiday_schemes do |t|
      t.string 'name'
      t.boolean 'active', default: false
      t.timestamps
    end
    add_reference :holiday_schemes, :leave_year, index: true
  end
end
