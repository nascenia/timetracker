require 'rails_helper'

RSpec.describe "kpis/index", type: :view do
  before(:each) do
    assign(:kpis, [
      Kpi.create!(
        :title => "Title",
        :description => "MyText",
        :score => 2,
        :status => 3
      ),
      Kpi.create!(
        :title => "Title",
        :description => "MyText",
        :score => 2,
        :status => 3
      )
    ])
  end

  it "renders a list of kpis" do
    render
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
  end
end
