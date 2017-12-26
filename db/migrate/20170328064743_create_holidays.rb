class CreateHolidays < ActiveRecord::Migration
  def change
    create_table :holidays do |t|
      t.string 'name'
      t.date 'date'
      t.timestamps
    end
    add_reference :holidays, :holiday_scheme, index: true
  end
end
