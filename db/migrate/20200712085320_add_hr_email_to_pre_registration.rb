class AddHrEmailToPreRegistration < ActiveRecord::Migration
  def change
    add_column :pre_registrations, :HR_email, :string
  end
end
