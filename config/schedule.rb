every :day, :at => '5:45pm' do
  runner 'User.create_unannounced_leave', output: { error: 'log/error.log', standard: 'log/cron.log' }
end

every :day, :at => '5:50pm' do
  runner 'User.create_unannounced_leave', output: { error: 'log/error.log', standard: 'log/cron.log' }
end

# every 1.year, at: 'December 31st 11:58pm' do
#   runner 'LeaveTracker.update_leave_tracker_yearly'
# end

# every 1.year, at: 'January 1st 12:00am' do
#   runner 'LeaveTracker.initialize_every_leave_with_new_year'
# end
