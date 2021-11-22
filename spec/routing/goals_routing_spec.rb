require "rails_helper"

RSpec.describe GoalsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/goals").to route_to("goals#index")
    end

    it "routes to #new" do
      expect(:get => "/goals/new").to route_to("goals#new")
    end

    it "routes to #show" do
      expect(:get => "/goals/1").to route_to("goals#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/goals/1/edit").to route_to("goals#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/goals").to route_to("goals#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/goals/1").to route_to("goals#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/goals/1").to route_to("goals#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/goals/1").to route_to("goals#destroy", :id => "1")
    end

  end
end
