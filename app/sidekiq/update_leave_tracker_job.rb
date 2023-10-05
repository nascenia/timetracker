class UpdateLeaveTrackerJob
  include Sidekiq::Job

  def perform(*args)
    LeaveTracker.update_leave_tracker_yearly
  end
end
