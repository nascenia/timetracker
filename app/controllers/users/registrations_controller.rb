# :nodoc:
class Users::RegistrationsController < Devise::RegistrationsController
  layout 'time_tracker'

  protected

  def account_update_params
    params.require(:user).permit(
      :ttf_id,
      :personal_email,
      :present_address,
      :mobile_number,
      :alternate_contact,
      :permanent_address,
      :date_of_birth,
      :last_degree,
      :last_university,
      :passing_year,
      :emergency_contact_person_name,
      :emergency_contact_person_relation,
      :emergency_contact_person_number,
      :blood_group,
      :joining_date,
      :name,
      :avatar,
      :resume,
      :national_id,
      :passport,
      :bank_account_no)
  end

  def update_resource(resource, params)
    hash = {
      ttf_id: params[:ttf_id],
      personal_email: params[:personal_email],
      present_address: params[:present_address], 
      mobile_number: params[:mobile_number], 
      alternate_contact: params[:alternate_contact], 
      permanent_address: params[:permanent_address], 
      date_of_birth: params[:date_of_birth].to_date, 
      last_degree: params[:last_degree],
      last_university: params[:last_university], 
      passing_year: params[:passing_year], 
      emergency_contact_person_name: params[:emergency_contact_person_name], 
      emergency_contact_person_relation: params[:emergency_contact_person_relation], 
      emergency_contact_person_number: params[:emergency_contact_person_number], 
      blood_group: params[:blood_group], 
      joining_date: params[:joining_date].to_date, 
      name: params[:name],
      bank_account_no: params[:bank_account_no]
    }

    file_data = {
      avatar: params[:avatar],
      resume: params[:resume],
      national_id: params[:national_id],
      passport: params[:passport]
    }
    resource.update_without_password(file_data)
    resource.update_attributes(profile_update_json: hash.to_json, registration_status: User::REGISTRATION_STATUS[:not_approved])

    UserMailer.send_approval_or_rejection_notification_of_employee_registration_to_hr(resource).deliver
    #UserMailer.send_approval_or_rejection_notification_of_employee_registration_to_ceo(resource).deliver

    after_update_path_for(resource)
  end

  def after_update_path_for(resource)
    employee_path(resource)
  end

  def after_sign_up_path_for(resource)
    after_sign_in_path_for(resource)
  end
end
