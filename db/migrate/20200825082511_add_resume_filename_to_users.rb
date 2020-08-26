class AddResumeFilenameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :resume_filename, :string
  end
end
