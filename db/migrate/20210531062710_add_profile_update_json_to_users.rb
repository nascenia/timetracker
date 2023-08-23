class AddProfileUpdateJsonToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :profile_update_json, :text
  end
end
