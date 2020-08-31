ActiveAdmin.register User do
  permit_params :email, :name, :is_active, :role, :ttf_id, :sttf_id, :personal_email, :present_address, :mobile_number,
                :alternate_contact, :permanent_address, :date_of_birth, :last_degree, :last_university, :passing_year,
                :emergency_contact_person_name, :emergency_contact_person_relation, :emergency_contact_person_number,
                :blood_group, :joining_date, :resignation_date, :is_published, :bank_account_no, :passport, :national_id, :resume

  remove_filter :attendances, :leaves, :leave_tracker
  controller do
    def update
      if current_user.has_edit_permission_for?(User.find((id = params[:id])))
        update!
      else
        flash[:error] = "You don't have permission to edit. Contact the Super Admin."
        redirect_to(:edit_admin_user) && return
      end
    end

    def create
      if current_user.has_edit_permission_for?(User.find((id = params[:id])))
        create!
      else
        flash[:error] = "You don't have permission to create. Contact the Super Admin."
        redirect_to(:new_admin_user) && return
      end
    end
  end

  index do
    selectable_column
    id_column
    column :name
    column :role do |id|
      if id.role == User::EMPLOYEE
        'Employee'
      elsif id.role == User::TTF
        'TTF'
      elsif id.role == User::SUPER_TTF
        'Super TTF'
      else
        'Not assigned'
      end
    end
    column 'TTF' do |obj|
      (User.find obj.ttf_id).name if obj.ttf_id.present?
    end

    column 'Super TTF' do |obj|
      (User.find obj.sttf_id).name if obj.sttf_id.present?
    end

    column :is_active if actions
  end

  show do
    attributes_table do
      row :email
      row :name
      row :is_active
      row :role
      row :ttf_id
      row :sttf_id
      row :date_of_birth
      row :joining_date
      row 'Date of Last Working Day', &:resignation_date
      row :personal_email
      row :present_address
      row :mobile_number
      row :alternate_contact
      row :permanent_address
      row :last_degree
      row :last_university
      row :passing_year
      row :emergency_contact_person_name
      row :emergency_contact_person_relation
      row :emergency_contact_person_number
      row :bank_account_no
      row :resume
      row :national_id
      row :passport
    end
  end

  form do |f|
    f.inputs 'User Details' do
      f.input :email
      f.input :name
      f.input :is_active
      f.input :role, as: :select, collection: User::ROLES
      f.input :ttf_id, as: :select, collection: User.ttf
      f.input :sttf_id, as: :select, collection: User.super_ttf
      f.input :date_of_birth, start_year: 1970
      f.input :joining_date
      f.input :resignation_date, label: 'Date of Last Working Day'
      f.input :personal_email
      f.input :present_address
      f.input :mobile_number
      f.input :alternate_contact
      f.input :permanent_address
      f.input :last_degree
      f.input :last_university
      f.input :passing_year
      f.input :emergency_contact_person_name
      f.input :emergency_contact_person_relation
      f.input :emergency_contact_person_number
      # f.input :bank_account_no
      # f.input :resume
      # f.input :national_id, label: 'National ID / Birth Certificate'
      # f.input :passport
      f.input :is_published, input_html: { value: true }, as: :hidden
    end
    f.actions
  end
end
