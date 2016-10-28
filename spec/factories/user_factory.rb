FactoryGirl.define do
  factory :user do
    sequence(:name) { |n| "name-#{n}" }
    sequence(:email){|n| "example-#{n}@email.com"}
    password "11111111"
  end
end