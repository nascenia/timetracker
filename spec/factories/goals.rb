FactoryGirl.define do
  factory :goal do
    title "MyString"
    description "MyText"
    point "9.99"
    percent_completed "9.99"
    achived_point "9.99"
    deliverable_link "MyText"
    comments "MyText"
    start_date "2021-11-19"
    end_date "2021-11-19"
    status 1
  end
end
