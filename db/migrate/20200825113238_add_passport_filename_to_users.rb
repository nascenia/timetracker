class AddPassportFilenameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :passport_filename, :string
  end
end
