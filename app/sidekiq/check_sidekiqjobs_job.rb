class CheckSidekiqjobsJob
  include Sidekiq::Job

  def perform(*args)
    User.check_sidekiqjobs
  end
end
