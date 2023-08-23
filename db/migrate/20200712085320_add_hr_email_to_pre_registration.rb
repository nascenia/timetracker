class AddHrEmailToPreRegistration < ActiveRecord::Migration[7.0]
  def change
    add_column :pre_registrations, :HR_email, :string
  end
end
