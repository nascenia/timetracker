class AddNationalIdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :national_id, :string
  end
end
