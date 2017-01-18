FactoryGirl.define do
  factory :attendance do
    checkin_date Date.today
    in_time Time.now.to_s(:time)
  end
end