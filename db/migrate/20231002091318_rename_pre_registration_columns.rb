class RenamePreRegistrationColumns < ActiveRecord::Migration[7.0]
  def change
    rename_column :pre_registrations, :joiningDate, :joining_date
    rename_column :pre_registrations, :NdaSigned, :nda_signed
    rename_column :pre_registrations, :emailGroup, :email_group
    rename_column :pre_registrations, :contactNumber, :contact_number
    rename_column :pre_registrations, :personalEmail, :personal_email
    rename_column :pre_registrations, :companyEmail, :company_email
    rename_column :pre_registrations, :workstationReady, :workstation_ready
    rename_column :pre_registrations, :packReady, :pack_ready
    rename_column :pre_registrations, :ndaDoc, :nda_doc
    rename_column :pre_registrations, :HR_email, :hr_email
  end
end





