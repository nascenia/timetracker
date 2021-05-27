class AddFieldsToPreRegistration < ActiveRecord::Migration
  def change
    add_column :pre_registrations, :salary_account_details_sent, :boolean
    add_column :pre_registrations, :employee_contract_sign, :boolean
    add_column :pre_registrations, :id_card_given, :boolean
    add_column :pre_registrations, :pic_and_other_relevant_info, :boolean
    add_column :pre_registrations, :has_sent_invitation_to_visit_internal_website, :boolean
  end
end
