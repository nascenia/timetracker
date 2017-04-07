set :environment, ENV['RAILS_ENV']

every :day, at: '6.00 pm' do
  runner 'User.create_unannounced_leave', output: { error: 'log/error.log', standard: 'log/cron.log' }
end

every 1.month, at: 'December 31st 11:58pm' do
  runner 'LeaveTracker.update_leave_tracker_yearly'
end

every 1.month, at: 'January 1st 12:00am' do
  runner 'LeaveTracker.initialize_every_leave_with_new_year'
end
