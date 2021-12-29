require "rails_helper"

RSpec.describe KpisController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/kpis").to route_to("kpis#index")
    end

    it "routes to #new" do
      expect(:get => "/kpis/new").to route_to("kpis#new")
    end

    it "routes to #show" do
      expect(:get => "/kpis/1").to route_to("kpis#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/kpis/1/edit").to route_to("kpis#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/kpis").to route_to("kpis#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/kpis/1").to route_to("kpis#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/kpis/1").to route_to("kpis#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/kpis/1").to route_to("kpis#destroy", :id => "1")
    end

  end
end
