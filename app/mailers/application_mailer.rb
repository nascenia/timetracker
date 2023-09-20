class ApplicationMailer < ActionMailer::Base
  default from: "Leave Tracker | Nascenia <leave.nascenia@gmail.com>"
  layout "notification"
end
