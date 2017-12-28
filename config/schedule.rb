every :day, :at => '2:00pm' do
  runner 'User.create_unannounced_leave', output: { error: 'log/error.log', standard: 'log/cron.log' }
end

every :day, :at => '4:00pm' do
  runner 'User.create_unannounced_leave', output: { error: 'log/error.log', standard: 'log/cron.log' }
end

every :year, :at => '12:01am' do
  runner 'LeaveTracker.update_leave_tracker_yearly'
end

every :year, :at => '12:10am' do
  runner 'LeaveTracker.initialize_every_leave_with_new_year'
end
