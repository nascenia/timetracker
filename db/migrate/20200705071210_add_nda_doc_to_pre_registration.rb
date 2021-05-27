class AddNdaDocToPreRegistration < ActiveRecord::Migration
  def change
    add_column :pre_registrations, :ndaDoc, :string
  end
end
