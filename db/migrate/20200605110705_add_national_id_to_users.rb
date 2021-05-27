class AddNationalIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :national_id, :string
  end
end
