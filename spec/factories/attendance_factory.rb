FactoryGirl.define do
  factory :attendance do
    datetoday Time.now.to_s
  end
end