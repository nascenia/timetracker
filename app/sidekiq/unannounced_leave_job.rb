class UnannouncedLeaveJob
  include Sidekiq::Job

  def perform(*args)
    User.create_unannounced_leave
  end
end
