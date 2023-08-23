class AddNdaDocToPreRegistration < ActiveRecord::Migration[7.0]
  def change
    add_column :pre_registrations, :ndaDoc, :string
  end
end
