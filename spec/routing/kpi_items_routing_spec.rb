require "rails_helper"

RSpec.describe KpiItemsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/kpi_items").to route_to("kpi_items#index")
    end

    it "routes to #new" do
      expect(:get => "/kpi_items/new").to route_to("kpi_items#new")
    end

    it "routes to #show" do
      expect(:get => "/kpi_items/1").to route_to("kpi_items#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/kpi_items/1/edit").to route_to("kpi_items#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/kpi_items").to route_to("kpi_items#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/kpi_items/1").to route_to("kpi_items#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/kpi_items/1").to route_to("kpi_items#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/kpi_items/1").to route_to("kpi_items#destroy", :id => "1")
    end

  end
end
