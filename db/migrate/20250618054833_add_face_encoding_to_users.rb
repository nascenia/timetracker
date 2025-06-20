class AddFaceEncodingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :face_encoding, :text
  end
end
