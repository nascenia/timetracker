every :day, :at => '10:03am' do
  runner 'User.create_unannounced_leave', output: { error: 'log/error.log', standard: 'log/cron.log' }
end

every :day, :at => '2:03pm' do
  runner 'User.create_unannounced_leave', output: { error: 'log/error.log', standard: 'log/cron.log' }
end

every :day, :at => '4:03pm' do
  runner 'User.create_unannounced_leave', output: { error: 'log/error.log', standard: 'log/cron.log' }
end

every :day, :at => '07:31pm' do
  runner 'User.check_crontasks', output: { error: 'log/error.log', standard: 'log/cron.log' }
end

every '1 12 1 1 *' do
  runner 'LeaveTracker.update_leave_tracker_yearly'
end

every '10 12 1 1 *' do
  runner 'LeaveTracker.initialize_every_leave_with_new_year'
end
