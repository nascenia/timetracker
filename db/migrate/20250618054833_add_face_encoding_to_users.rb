class AddFaceEncodingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :face_encoding_pc, :text
    add_column :users, :face_encoding_mb, :text
  end
end
