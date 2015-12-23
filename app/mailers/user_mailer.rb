class UserMailer < ActionMailer::Base
  default from: 'Leave Tracker | Nascenia <no-reply@nascenia.com>',
          cc: 'khalid@nascenia.com'

  layout 'notification'

  def send_leave_application_notification(user, leave)
    @user = user
    @ttf = User.find @user.ttf_id
    @leave = leave

    mail :to => @ttf.email, :subject => "#{@user.name} has applied for a leave"
  end

  def send_approval_or_rejection_notification(leave)
    @leave = leave
    @user = @leave.user

    if @leave.status == Leave::ACCEPTED
      subject = 'Leave Approved'
      @title = 'Your leave application has just been approved.'
      @greetings = '- Enjoy Your Vacation!'
    else
      subject = 'Leave Rejected'
      @title = 'Your leave application has just been rejected.'
      @greetings = '- Better Luck Next Time!'
    end

    mail :to => user.email, :subject => subject
  end
end
