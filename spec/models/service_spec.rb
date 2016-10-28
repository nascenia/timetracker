require 'rails_helper'

RSpec.describe Service, type: :model do
  OTHERS = {
      tp: {
          name: 'Team planner',
          url: 'http://test.teamplanner.nascenia.com/'
      },
      kb: {
          name: 'Knowledge base',
          url: 'http://kb.nascenia.com/'
      },
      fs: {
          name: 'File server',
          url: 'http://192.168.1.2/'
      }
  }

  describe 'validation' do
    it 'should team planner' do
      expect(Service::OTHERS[:tp][:name]).to eq(OTHERS[:tp][:name])
      expect(Service::OTHERS[:tp][:url]).to eq(OTHERS[:tp][:url])
    end

    it 'should knowledge base' do
      expect(Service::OTHERS[:kb][:name]).to eq(OTHERS[:kb][:name])
      expect(Service::OTHERS[:kb][:url]).to eq(OTHERS[:kb][:url])
    end

    it 'should File Server' do
      expect(Service::OTHERS[:fs][:name]).to eq(OTHERS[:fs][:name])
      expect(Service::OTHERS[:fs][:url]).to eq(OTHERS[:fs][:url])
    end
  end
end