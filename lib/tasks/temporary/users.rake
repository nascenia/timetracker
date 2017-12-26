namespace :users do
  desc 'Create leave tracker for each user if it doesn\'t exist'
  task create_leave_trackers: :environment do
    ActiveRecord::Base.transaction do
      User.all.each do |user|
        unless user.leave_tracker.present?
          puts "Creating leave tracker for #{user.name}"
          LeaveTracker::create_leave_tracker(user)
        end
      end
    end
    puts 'Leave trackers created for users who did not have one!!!'
  end
end
