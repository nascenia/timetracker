class UserMailer < ActionMailer::Base
  add_template_helper ApplicationHelper

  default from: 'Leave Tracker | Nascenia <leave.nascenia@gmail.com>'

  layout 'notification'

  def send_leave_application_notification(leave, email)

    @leave = leave
    @user = @leave.user
    @email = email

    mail to: @email, subject: "#{@user.name} has applied for a leave"
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
    mail to: @user.email, subject: subject
    true
    rescue => e
    logger.error e.message
    false
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
    mail to: 'afroze@nascenia.com', subject: subject
    true
    rescue => e
    logger.error e.message
    false
  end

  def send_unannounced_leave_notification_to_user(leave)
    @leave = leave
    @user = @leave.user
    subject = 'Unannounced leave'
    @greetings = ''

    mail to: @user.email, subject: subject
    true
    rescue => e
    logger.error e.message
    false
  end

  def send_unannounced_leave_notification_to_admin(leave, email)
    @leave = leave
    @user = @leave.user
    subject = 'Unannounced leave'
    @greetings = ''

    mail to: email, subject: subject
    true
  rescue => e
    logger.error e.message
    false
  end

  def send_leave_type_change_notification(leave)
    @leave = leave
    @user = @leave.user
    subject = "Unannounced leave Converted to #{Leave::LEAVE_TYPES.to_h.key(@leave.leave_type)}"
    @greetings = '- Have a nice day!'

    mail to: @user.email, subject: subject
    true
  rescue => e
    logger.error e.message
    false
  end
end
