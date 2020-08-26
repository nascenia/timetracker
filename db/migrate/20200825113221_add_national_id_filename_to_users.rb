class AddNationalIdFilenameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :national_id_filename, :string
  end
end
