require 'rails_helper'

RSpec.describe "kpi_items/new", type: :view do
  before(:each) do
    assign(:kpi_item, KpiItem.new(
      :title => "MyString",
      :description => "MyText",
      :score => 1,
      :status => 1
    ))
  end

  it "renders new kpi_item form" do
    render

    assert_select "form[action=?][method=?]", kpi_items_path, "post" do

      assert_select "input#kpi_item_title[name=?]", "kpi_item[title]"

      assert_select "textarea#kpi_item_description[name=?]", "kpi_item[description]"

      assert_select "input#kpi_item_score[name=?]", "kpi_item[score]"

      assert_select "input#kpi_item_status[name=?]", "kpi_item[status]"
    end
  end
end
