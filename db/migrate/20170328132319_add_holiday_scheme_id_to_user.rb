class AddHolidaySchemeIdToUser < ActiveRecord::Migration[7.0]
  def change
    add_reference :users, :holiday_scheme, index: true
  end
end
