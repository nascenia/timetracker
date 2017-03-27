class AddWeekendIdToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :weekend, index: true
  end
end
