require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

scheduler.in '5s' do
  HardJob.perform_async
end
