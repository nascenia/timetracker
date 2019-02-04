every :day, :at => '11:00am' do
  runner 'User.create_unannounced_leave', output: { error: 'log/error.log', standard: 'log/cron.log' }
end

every :day, :at => '2:00pm' do
  runner 'User.create_unannounced_leave', output: { error: 'log/error.log', standard: 'log/cron.log' }
end

every :day, :at => '4:00pm' do
  runner 'User.create_unannounced_leave', output: { error: 'log/error.log', standard: 'log/cron.log' }
end

every '1 12 1 1 *' do
  runner 'LeaveTracker.update_leave_tracker_yearly'
end

every '10 12 1 1 *' do
  runner 'LeaveTracker.initialize_every_leave_with_new_year'
end
