require 'rails_helper'

RSpec.describe "goals/edit", type: :view do
  before(:each) do
    @goal = assign(:goal, Goal.create!(
      :title => "MyString",
      :description => "MyText",
      :point => "9.99",
      :percent_completed => "9.99",
      :achived_point => "9.99",
      :deliverable_link => "MyText",
      :comments => "MyText",
      :status => 1
    ))
  end

  it "renders the edit goal form" do
    render

    assert_select "form[action=?][method=?]", goal_path(@goal), "post" do

      assert_select "input#goal_title[name=?]", "goal[title]"

      assert_select "textarea#goal_description[name=?]", "goal[description]"

      assert_select "input#goal_point[name=?]", "goal[point]"

      assert_select "input#goal_percent_completed[name=?]", "goal[percent_completed]"

      assert_select "input#goal_achived_point[name=?]", "goal[achived_point]"

      assert_select "textarea#goal_deliverable_link[name=?]", "goal[deliverable_link]"

      assert_select "textarea#goal_comments[name=?]", "goal[comments]"

      assert_select "input#goal_status[name=?]", "goal[status]"
    end
  end
end
