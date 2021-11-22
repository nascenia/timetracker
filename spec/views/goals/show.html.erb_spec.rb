require 'rails_helper'

RSpec.describe "goals/show", type: :view do
  before(:each) do
    @goal = assign(:goal, Goal.create!(
      :title => "Title",
      :description => "MyText",
      :point => "9.99",
      :percent_completed => "9.99",
      :achived_point => "9.99",
      :deliverable_link => "MyText",
      :comments => "MyText",
      :status => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/2/)
  end
end
