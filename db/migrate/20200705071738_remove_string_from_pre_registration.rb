class RemoveStringFromPreRegistration < ActiveRecord::Migration
  def change
    remove_column :pre_registrations, :string, :string
  end
end
