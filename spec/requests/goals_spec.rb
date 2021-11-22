require 'rails_helper'

RSpec.describe "Goals", type: :request do
  describe "GET /goals" do
    it "works! (now write some real specs)" do
      get goals_path
      expect(response).to have_http_status(200)
    end
  end
end
