require 'rails_helper'

RSpec.describe "KpiItems", type: :request do
  describe "GET /kpi_items" do
    it "works! (now write some real specs)" do
      get kpi_items_path
      expect(response).to have_http_status(200)
    end
  end
end
