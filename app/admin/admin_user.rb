ActiveAdmin.register AdminUser do
  permit_params :email, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  show do
    attributes_table :email, :name, :is_active, :role, :ttf_id, :sttf_id, :date_of_birth, :joining_date,
                     :resignation_date, :personal_email, :present_address, :mobile_number, :alternate_contact,
                     :permanent_address, :last_degree, :last_university, :passing_year, :emergency_contact_person_name,
                     :emergency_contact_person_relation, :emergency_contact_person_relation,  :emergency_contact_person_number
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

end
