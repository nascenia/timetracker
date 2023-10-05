require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

scheduler.cron '01 10 * * *' do
  UnannouncedLeaveJob.perform_async
end

scheduler.cron '01 14 * * *' do
  UnannouncedLeaveJob.perform_async
end

scheduler.cron '01 16 * * *' do
  UnannouncedLeaveJob.perform_async
end

scheduler.cron '31 19 * * *' do
  CheckSidekiqjobsJob.perform_async
end

scheduler.cron '1 12 1 1 *' do
  UpdateLeaveTrackerJob.perform_async
end

scheduler.cron '10 12 1 1 *' do
  InitializeEveryLeaveJob.perform_async
end
