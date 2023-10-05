class HardJob
  include Sidekiq::Job

  def perform(*args)
    puts "This is hard job"
  end
end
