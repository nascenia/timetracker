class AddProfileUpdateJsonToUsers < ActiveRecord::Migration
  def change
    add_column :users, :profile_update_json, :json
  end
end
