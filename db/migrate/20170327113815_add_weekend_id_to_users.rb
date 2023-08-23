class AddWeekendIdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_reference :users, :weekend, index: true
  end
end
