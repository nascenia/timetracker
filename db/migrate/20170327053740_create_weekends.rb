class CreateWeekends < ActiveRecord::Migration[7.0]
  def change
    create_table :weekends do |t|
      t.string 'name'
      t.boolean 'saturday', default: false
      t.boolean 'sunday', default: false
      t.boolean 'monday', default: false
      t.boolean 'tuesday', default: false
      t.boolean 'wednesday', default: false
      t.boolean 'thursday', default: false
      t.boolean 'friday', default: false
      t.timestamps
    end
  end
end
