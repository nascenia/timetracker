class AddPassportToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :passport, :string
  end
end
