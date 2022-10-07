# :nodoc:
class UserMailer < ActionMailer::Base
  add_template_helper ApplicationHelper

  default from: 'Leave Tracker | Nascenia <leave.nascenia@gmail.com>'

  layout 'notification'

  PRE_FIX  = Rails.env.staging? ? '' : '[Test]: ' # as staging is using as production application

  def welcome
    @greeting = "Hi"

    mail to: "masud@nascenia.com", subject: 'Greeting'
  end

  def send_leave_application_notification(leave, email)
    @leave = leave
    @user = @leave.user
    @email = email
    approver_ids = @leave.approval_path.path_chains.where('priority > ?', @leave.pending_at).pluck(:user_id)
    @approvers = User.where(id: approver_ids).pluck(:name)
    if CONFIG['leave_admin'].include?(email)
      subject = "Action required: #{@user.name} has applied for a leave."
    else
      subject = "#{@user.name} has applied for a leave"
    end

    subject = PRE_FIX + subject
   
    mail to: @email,
         cc: CONFIG['leave_admin'],
         subject: subject
    true
  end

  def send_approval_or_rejection_notification(leave)
    @leave = leave
    @user = @leave.user
    if @leave.is_accepted?
      subject = 'Leave Approved'
      @title = 'Your leave application has just been approved.'
      @greetings = '- Enjoy your vacation!'
    elsif @leave.is_rejected?
      subject = 'Leave Rejected'
      @title = 'Your leave application has just been rejected.'
      @greetings = '- Better luck next time!'
    end

    subject = PRE_FIX + subject

    mail to: @user.email,
         cc: CONFIG['leave_admin'],
         subject: subject
    true
    rescue => e
      logger.error e.message
    false
    true
  end

  def send_rejection_notification_of_employee_registration_to_user(user, reason)
    @user = user
    @reason = reason
    subject = 'Employee Registration Form Rejected'
    @title = 'Your employee registration application has just been rejected.'
    @greetings = '- Better luck next time!'
    subject = PRE_FIX + subject

    mail to: @user.email,
         cc: CONFIG['leave_admin'],
         subject: subject
    true
    rescue => e
      logger.error e.message
    false
    true
  end

  def send_approval_or_rejection_notification_to_hr(leave)
    @leave = leave
    @user = @leave.user
    if @leave.is_accepted?
      subject = 'Leave Approved'
      @title = 'A leave application has just been approved.'
    elsif @leave.is_rejected?
      subject = 'Leave Rejected'
      @title = 'A leave application has just been rejected.'
    end

    subject = PRE_FIX + subject

    mail to: CONFIG['leave_admin'],
         subject: subject
    true
    rescue => e
      logger.error e.message
    false
    true
  end
  
  def send_award_leave_notification_to_user(user, hours)
    @user = user
    @hours = hours
    subject = 'Leave Awarded'
    subject = PRE_FIX + subject

    mail to: @user.email, subject: subject
    true
  end

  def send_unannounced_leave_notification_to_user(leave)
    @leave = leave
    @user = @leave.user
    if @leave.half_day == Leave::FIRST_QUARTER
      subject = '2 hours of unannounced leave'
      @leave_hour = '2'
    elsif @leave.half_day == Leave::FIRST_HALF
      subject = 'Half day of unannounced leave'
      @leave_hour = '4'
    else
      subject = 'Full day of unannounced leave'
      @leave_hour = '8'
    end
    @greetings = ''
    subject = PRE_FIX + subject

    mail to: @user.email,
         subject: subject
    true
    rescue => e
      logger.error e.message
    false
    true
  end

  def send_unannounced_leave_notification_to_admin(leave, email)
    @leave = leave
    @user = @leave.user
    if @leave.half_day == Leave::FIRST_QUARTER
      subject = "2 hours of unannounced leave by #{@user.name}"
      @leave_hour = '2'
    elsif @leave.half_day == Leave::FIRST_HALF
      subject = "Half day of unannounced leave by #{@user.name}"
      @leave_hour = '4'
    else
      subject = "Full day of unannounced leave by #{@user.name}"
      @leave_hour = '8'
    end
    @greetings = ''
    subject = PRE_FIX + subject

    mail to: email,
         subject: subject
    true
    rescue => e
      logger.error e.message
    false
    true
  end

  def send_leave_type_change_notification(leave)
    @leave = leave
    @user = @leave.user
    subject = "Unannounced leave Converted to #{Leave::LEAVE_TYPES.to_h.key(@leave.leave_type)}"
    @greetings = '- Have a nice day!'
    subject = PRE_FIX + subject

    mail to: @user.email, subject: subject
    true
    rescue => e
      logger.error e.message
    false
    true
  end

  def send_new_employee_notification(pre_registration)
    @pre_registration = pre_registration
    subject = 'Action required to open new email account for a new employee'
    @greetings = '- Have a nice day!'
    subject = PRE_FIX + subject

    mail to: ENV['TT_CEO_EMAIL'],
         subject: subject
    true
    rescue => e
      logger.error e.message
    false
    true
  end

  def send_mail_to_new_employee_about_tt(pre_registration, zoho_email_account)
    @pre_registration = pre_registration
    @zoho_email_account = zoho_email_account
    subject = 'Invitation to Time tracker with new email ID'
    subject = PRE_FIX + subject

    mail to: @pre_registration.companyEmail,
         subject: subject
    true
    rescue => e
      logger.error e.message
    false
    true
  end
  
  def send_mail_to_hr_about_new_employee(pre_registration)
    @pre_registration = pre_registration
    @HR_email = pre_registration.HR_email
    subject = 'Action required to prepare documents and arrangements for new employee'
    subject = PRE_FIX + subject

    mail to: @HR_email,
         subject: subject
    true
  rescue => e
    logger.error e.message
  false
  true
  end

  def send_approval_or_rejection_notification_of_employee_registration_to_hr(user)
    @user = user
    subject = 'Action required: Change(s) detected in employee information and approval needed'
    subject = PRE_FIX + subject

    mail to: 'hr@nascenia.com', subject: subject
    true
   rescue => e
    logger.error e.message
    false
    true
  end

  def send_approval_or_rejection_notification_of_employee_registration_to_ceo(user)
  #  @user = user
  #  subject = 'Action required: Change(s) detected in employee information and approval needed'
  #  subject = PRE_FIX + subject

  #  mail to: 'nasceniatest2@gmail.com', subject: subject

  #  true
  # rescue => e
  #  logger.error e.message
  #  false
  #  true
  end
end
