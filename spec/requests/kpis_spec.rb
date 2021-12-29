require 'rails_helper'

RSpec.describe "Kpis", type: :request do
  describe "GET /kpis" do
    it "works! (now write some real specs)" do
      get kpis_path
      expect(response).to have_http_status(200)
    end
  end
end
