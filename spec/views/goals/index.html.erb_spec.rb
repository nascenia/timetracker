require 'rails_helper'

RSpec.describe "goals/index", type: :view do
  before(:each) do
    assign(:goals, [
      Goal.create!(
        :title => "Title",
        :description => "MyText",
        :point => "9.99",
        :percent_completed => "9.99",
        :achived_point => "9.99",
        :deliverable_link => "MyText",
        :comments => "MyText",
        :status => 2
      ),
      Goal.create!(
        :title => "Title",
        :description => "MyText",
        :point => "9.99",
        :percent_completed => "9.99",
        :achived_point => "9.99",
        :deliverable_link => "MyText",
        :comments => "MyText",
        :status => 2
      )
    ])
  end

  it "renders a list of goals" do
    render
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
