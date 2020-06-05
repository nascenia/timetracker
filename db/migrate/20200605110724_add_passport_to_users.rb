class AddPassportToUsers < ActiveRecord::Migration
  def change
    add_column :users, :passport, :string
  end
end
