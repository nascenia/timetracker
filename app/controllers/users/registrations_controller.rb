# :nodoc:
class Users::RegistrationsController < Devise::RegistrationsController
  before_action :signup_invitation_validation, only: [:new, :create]
  
  layout 'timetracker'

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
    hash                                      = Hash.new
    hash[:ttf_id]                             = params[:ttf_id] unless params[:ttf_id].blank?
    hash[:name]                               = params[:name] unless params[:name].blank?
    hash[:personal_email]                     = params[:personal_email] unless params[:personal_email].blank?
    hash[:present_address]                    = params[:present_address] unless params[:present_address].blank?
    hash[:mobile_number]                      = params[:mobile_number] unless params[:mobile_number].blank?
    hash[:alternate_contact]                  = params[:alternate_contact] unless params[:alternate_contact].blank?
    hash[:permanent_address]                  = params[:permanent_address] unless params[:permanent_address].blank?
    hash[:date_of_birth]                      = params[:date_of_birth].to_date unless params[:date_of_birth].blank?
    hash[:last_degree]                        = params[:last_degree] unless params[:last_degree].blank?
    hash[:last_university]                    = params[:last_university] unless params[:last_university].blank?
    hash[:passing_year]                       = params[:passing_year] unless params[:passing_year].blank?
    hash[:emergency_contact_person_name]      = params[:emergency_contact_person_name] unless params[:emergency_contact_person_name].blank?
    hash[:emergency_contact_person_relation]  = params[:emergency_contact_person_relation] unless params[:emergency_contact_person_relation].blank?
    hash[:emergency_contact_person_number]    = params[:emergency_contact_person_number] unless params[:emergency_contact_person_number].blank?
    hash[:blood_group]                        = params[:blood_group] unless params[:blood_group].blank?
    hash[:joining_date]                       = params[:joining_date].to_date unless params[:joining_date].blank?
    hash[:bank_account_no]                    = params[:bank_account_no] unless params[:bank_account_no].blank?

    file_data = {
      avatar: params[:avatar],
      resume: params[:resume],
      national_id: params[:national_id],
      passport: params[:passport]
    }
    resource.update_without_password(file_data) unless params[:name].blank?
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

  private

  def signup_invitation_validation
    user = User.find_by(email: params[:email])

    if user.present?
      flash[:notice] = 'You are already a registered user.'

      redirect_to new_user_session_path && return
    end
    
    pr = PreRegistration.find_by(company_email: params[:email]) # TODO: Add invitation token

    if pr.blank?
      flash[:alert] = 'Sorry, you are not invited to register.'

      redirect_to root_path && return
    end
  end

end
