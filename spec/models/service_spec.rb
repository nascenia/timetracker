require 'rails_helper'

RSpec.describe Service, type: :model do
  describe 'validation' do
    it 'should be team planner' do
      expect(Service::INTERNAL['team_planner']['name']).to eq('Team planner')
      expect(Service::INTERNAL['team_planner']['url']).to eq('http://test.teamplanner.nascenia.com/')
    end

    it 'should be knowledge base' do
      expect(Service::INTERNAL['knowledge_base']['name']).to eq('Knowledge base')
      expect(Service::INTERNAL['knowledge_base']['url']).to eq('http://kb.nascenia.com/')
    end

    it 'should be file Server' do
      expect(Service::INTERNAL['file_server']['name']).to eq('File server')
      expect(Service::INTERNAL['file_server']['url']).to eq('http://192.168.1.2/')
    end
  end
end