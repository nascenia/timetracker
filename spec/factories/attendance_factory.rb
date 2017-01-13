FactoryGirl.define do
  factory :attendance do
    checkin_date Time.now.to_s
  end
end