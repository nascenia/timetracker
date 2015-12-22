ActiveAdmin.register User do

  permit_params :email, :name, :role, :ttf_id, :sttf_id

  index do
    selectable_column
    id_column
    column :name
    column :role do |id|
      if id.role == 1
        'Employee'
      elsif id.role == 2
        'TTF'
      elsif id.role == 3
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

    column :is_active
    actions
  end

  form do |f|
    f.inputs "User Details" do
      f.input :email
      f.input :name
      f.input :role, as: :select, collection: User::ROLES
      f.input :ttf_id, as: :select, collection: User.ttfs
      f.input :sttf_id, as: :select, collection: User.sttfs
    end
    f.actions
  end

end
