class AddRegisteredFaceToUsers < ActiveRecord::Migration
  def change
    add_column :users, :registered_face, :string
  end
end
