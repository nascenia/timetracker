ActiveAdmin.register LeaveTracker do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :yearly_casual_leave, :yearly_medical_leave, :carried_forward_vacation, :carried_forward_medical, :accrued_vacation_balance, :accrued_medical_balance, :consumed_medical, :consumed_vacation, :accrued_vacation_this_year, :accrued_medical_this_year, :accrued_vacation_total, :accrued_medical_total, :commenced_date, :awarded_leave, :note, :user_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:yearly_casual_leave, :yearly_medical_leave, :carried_forward_vacation, :carried_forward_medical, :accrued_vacation_balance, :accrued_medical_balance, :consumed_medical, :consumed_vacation, :accrued_vacation_this_year, :accrued_medical_this_year, :accrued_vacation_total, :accrued_medical_total, :commenced_date, :awarded_leave, :note, :user_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
