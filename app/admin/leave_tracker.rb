ActiveAdmin.register LeaveTracker do
  permit_params :user_id, :yearly_casual_leave, :yearly_medical_leave, :carried_forward_casual,
                :carried_forward_medical, :accrued_casual_leave, :accrued_medical_leave, :status,
                :consumed_casual_leave, :consumed_medical_leave

  index do
    selectable_column
    id_column
    column 'User' do |obj|
      obj.user.name if obj.user.present?
    end
    column :accrued_casual_leave
    column :accrued_medical_leave
    column :consumed_casual_leave
    column :consumed_medical_leave
    actions
  end

  form do |f|
    f.inputs "User Details" do
      f.input :accrued_casual_leave
      f.input :accrued_medical_leave
      f.input :consumed_casual_leave
      f.input :consumed_medical_leave
      f.input :carried_forward_casual
      f.input :carried_forward_medical
    end
    f.actions
  end

end
