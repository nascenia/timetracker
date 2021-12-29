require 'rails_helper'

RSpec.describe "kpis/edit", type: :view do
  before(:each) do
    @kpi = assign(:kpi, Kpi.create!(
      :title => "MyString",
      :description => "MyText",
      :score => 1,
      :status => 1
    ))
  end

  it "renders the edit kpi form" do
    render

    assert_select "form[action=?][method=?]", kpi_path(@kpi), "post" do

      assert_select "input#kpi_title[name=?]", "kpi[title]"

      assert_select "textarea#kpi_description[name=?]", "kpi[description]"

      assert_select "input#kpi_score[name=?]", "kpi[score]"

      assert_select "input#kpi_status[name=?]", "kpi[status]"
    end
  end
end
