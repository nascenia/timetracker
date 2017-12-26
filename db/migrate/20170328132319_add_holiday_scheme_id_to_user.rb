class AddHolidaySchemeIdToUser < ActiveRecord::Migration
  def change
    add_reference :users, :holiday_scheme, index: true
  end
end
