require 'rails_helper'

RSpec.describe "kpis/new", type: :view do
  before(:each) do
    assign(:kpi, Kpi.new(
      :title => "MyString",
      :description => "MyText",
      :score => 1,
      :status => 1
    ))
  end

  it "renders new kpi form" do
    render

    assert_select "form[action=?][method=?]", kpis_path, "post" do

      assert_select "input#kpi_title[name=?]", "kpi[title]"

      assert_select "textarea#kpi_description[name=?]", "kpi[description]"

      assert_select "input#kpi_score[name=?]", "kpi[score]"

      assert_select "input#kpi_status[name=?]", "kpi[status]"
    end
  end
end
