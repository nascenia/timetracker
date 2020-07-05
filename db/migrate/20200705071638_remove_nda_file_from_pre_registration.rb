class RemoveNdaFileFromPreRegistration < ActiveRecord::Migration
  def change
    remove_column :pre_registrations, :ndaFile, :string
  end
end
