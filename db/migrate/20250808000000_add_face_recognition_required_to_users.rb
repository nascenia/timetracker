class AddFaceRecognitionRequiredToUsers < ActiveRecord::Migration
  def change
    add_column :users, :face_recognition_required, :boolean, default: true, null: false
    add_index :users, :face_recognition_required
  end
end
