class InitializeEveryLeaveJob
  include Sidekiq::Job

  def perform(*args)
    LeaveTracker.initialize_every_leave_with_new_year
  end
end
