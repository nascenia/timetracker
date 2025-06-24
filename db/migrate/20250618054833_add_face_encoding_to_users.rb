class AddFaceEncodingToUsers < ActiveRecord::Migration
  def change
    change_column :users, :face_encoding, :json
  end
end
