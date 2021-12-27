require 'rails_helper'

RSpec.describe "kpi_items/show", type: :view do
  before(:each) do
    @kpi_item = assign(:kpi_item, KpiItem.create!(
      :title => "Title",
      :description => "MyText",
      :score => 2,
      :status => 3
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
  end
end
