require 'rails_helper'

RSpec.describe "kpi_items/index", type: :view do
  before(:each) do
    assign(:kpi_items, [
      KpiItem.create!(
        :title => "Title",
        :description => "MyText",
        :score => 2,
        :status => 3
      ),
      KpiItem.create!(
        :title => "Title",
        :description => "MyText",
        :score => 2,
        :status => 3
      )
    ])
  end

  it "renders a list of kpi_items" do
    render
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
  end
end
