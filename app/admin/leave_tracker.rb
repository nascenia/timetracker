ActiveAdmin.register LeaveTracker do
  permit_params :user_id, :yearly_casual_leave, :yearly_medical_leave, :carried_forward_vacation,
                :carried_forward_medical, :accrued_vacation_balance, :accrued_medical_balance, :consumed_vacation,
                :consumed_medical, :commenced_date, :rewarded_leave, :note, :accrued_vacation_this_year,
                :accrued_medical_this_year, :accrued_vacation_total, :accrued_medical_total, :awarded_leave

  index do
    selectable_column
    id_column
    column 'User' do |obj|
      obj.user.name if obj.user.present?
    end
    column :accrued_vacation_balance
    column :accrued_medical_balance
    column :consumed_vacation
    column :consumed_medical
    column :commenced_date
    actions
  end

  form do |f|
    f.inputs "User Details" do
      f.input :accrued_vacation_this_year
      f.input :accrued_medical_this_year
      f.input :carried_forward_vacation
      f.input :carried_forward_medical
      f.input :accrued_vacation_total
      f.input :accrued_medical_total
      f.input :consumed_vacation
      f.input :consumed_medical
      f.input :awarded_leave
      f.input :accrued_vacation_balance
      f.input :accrued_medical_balance
      f.input :commenced_date
      f.input :note
    end
    f.actions
  end
end
