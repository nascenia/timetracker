require 'rails_helper'

RSpec.describe Attendance, type: :model do

  describe 'associations' do
    it 'should belong to user' do
      attendance = Attendance.reflect_on_association(:user)

      expect(attendance.macro).to eq(:belongs_to)
      expect(attendance.name).to eq(:user)
    end
  end

  ATTENDANCE = {
      USUAL_OFFICE_TIME: '10:00',
      IP_WHITELIST: ['203.202.242.130', '127.0.0.1']
  }

  describe 'validations' do
    it 'should be usual office time' do
      expect(Attendance::USUAL_OFFICE_TIME).to eq(ATTENDANCE[:USUAL_OFFICE_TIME])
    end

    it 'should be first ip from whitelist' do
      expect(Attendance::IP_WHITELIST[0]).to eq(ATTENDANCE[:IP_WHITELIST][0])
    end

    it 'should be second ip from whitelist' do
      expect(Attendance::IP_WHITELIST[1]).to eq(ATTENDANCE[:IP_WHITELIST][1])
    end
  end

  describe 'update_out_time' do
    let(:attendance) { create :attendance, in_time: Time.now.to_s(:time) }
    it 'should update out time' do
      attendance.update_out_time
      expect(attendance.total_hours).to eq(((Time.now.to_s(:time).to_time - Time.now.to_s(:time).to_time)  / 1.hour).round(2))
    end
  end

  # this method is never used!
  # describe 'summary_of_current_month' do
  #   let(:attendance) { create :attendance }
  #   it 'should get summary of current month' do
  #     attendance.summary_of_current_month
  #     expect('a').to eq('a')
  #   end
  # end
end