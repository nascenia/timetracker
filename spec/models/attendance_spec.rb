require 'rails_helper'

RSpec.describe Attendance, type: :model do

  describe 'associations' do
    it 'should belong to user' do
      attendance = Attendance.reflect_on_association(:user)

      expect(attendance.macro).to eq(:belongs_to)
      expect(attendance.name).to eq(:user)
    end

    it 'should have many(multi-entry) attendance' do
      attendance = Attendance.reflect_on_association(:children)

      expect(attendance.macro).to eq(:has_many)
      expect(attendance.name).to eq(:children)
    end
  end

  describe 'validations' do
    it 'should be usual office time' do
      expect(Attendance::USUAL_OFFICE_TIME).to eq('10:00')
    end

    it 'should validate whitelist IP addresses' do
      expect(Attendance::IP_WHITELIST[0]).to eq('203.202.242.130')
      expect(Attendance::IP_WHITELIST[1]).to eq('120.50.7.126')
      expect(Attendance::IP_WHITELIST[2]).to eq('127.0.0.1')
    end

    it 'should validate months year' do
      expect(Attendance::MONTHS.size).to eq(12)
    end
  end

  describe 'scope by_month_and_year' do

    let!(:user) {create :user}
    let!(:attendance) {create :attendance, user: user}

    context 'by month and year' do
      it 'attendance found by month and year' do
        attendance = Attendance.by_month_and_year(Date.today.strftime('%m'), Date.today.strftime('%Y'))
        expect(attendance[0].checkin_date.strftime('%m')).to eq(Date.today.strftime('%m'))
        expect(attendance[0].checkin_date.strftime('%Y')).to eq(Date.today.strftime('%Y'))
      end

      it 'attendance should be zero if not found by month and year' do
        attendance = Attendance.by_month_and_year(1.month.ago.strftime('%m'), 1.year.ago.strftime('%Y'))
        expect(attendance.size).to eq(0)
      end
    end
  end

  describe 'named scope daily_attendance_summary' do

    let(:users) {create_list :user, 5}
    let!(:user1_attendance) {create :attendance, user: users[0]}
    let!(:user2_attendance) {create :attendance, user: users[1]}
    let!(:user3_attendance) {create :attendance, user: users[2]}
    let!(:user4_attendance) {create :attendance, user: users[3]}
    let!(:user5_attendance) {create :attendance, user: users[4]}

    context 'daily attendance summary' do
      it 'returns daily attendance' do
        attendances = Attendance.daily_attendance_summary(Date.today)
        expect(attendances.size).to eq(5)
      end
    end
  end

  describe 'scope last six months' do

    let!(:users) {create_list :user, 3}
    let!(:user1_attendance) {create :attendance, user: users[0]}
    let!(:user2_attendance) {create :attendance, user: users[1]}
    let!(:user3_attendance) {create :attendance, user: users[2]}

    context 'last six months' do
      it 'returns last six months attendance' do
        attendances = Attendance.last_six_months
        expect(attendances.size).to eq(3)
      end
    end
  end

  describe 'scope monthly_attendance_summary' do

    let!(:user) {create :user}
    let!(:attendance_1) {create :attendance, user: user, checkin_date: 2.day.ago, in_time: Time.now - 2.hours, out_time: Time.now + 6.hours, total_hours: 8.0}
    let!(:attendance_2) {create :attendance, user: user, checkin_date: 1.day.ago, in_time: Time.now - 2.hours, out_time: Time.now + 6.hours, total_hours: 8.0}
    let!(:attendance_3) {create :attendance, user: user, checkin_date: Date.today, in_time: Time.now - 2.hours, out_time: Time.now + 6.hours, total_hours: 8.0}

    context 'monthly attendance summary' do
      it 'returns monthly attendance summary' do
        attendances = Attendance.monthly_attendance_summary(Date.today.at_beginning_of_month, Date.today)
        expect(Attendance.monthly_total_hours(attendances)).to eq(24)
        expect(Attendance.monthly_average_hours(attendances)).to eq(8)
      end
    end
  end

  describe 'scope find_first_entry' do

    let!(:user) {create :user}
    let!(:attendance_1) {create :attendance, user: user, checkin_date: 2.day.ago, in_time: Time.now - 2.hours, out_time: Time.now, total_hours: 2.0}
    let!(:attendance_2) {create :attendance, user: user, checkin_date: 1.day.ago, in_time: Time.now, out_time: Time.now + 6.hours, total_hours: 6.0, parent_id: attendance_1.id}

    context 'find first entry from multiple checkin' do
      it 'returns first checkin' do
        attendance = Attendance.find_first_entry(user.id, Date.today)
        expect(attendance.parent_id).to eq(nil)
      end
    end
  end

  describe 'scope find_last_entry' do

    let!(:user) {create :user}
    let!(:attendance_1) {create :attendance, user: user, checkin_date: 2.day.ago, in_time: Time.now - 2.hours, out_time: Time.now, total_hours: 2.0}
    let!(:attendance_2) {create :attendance, user: user, checkin_date: 1.day.ago, in_time: Time.now, out_time: Time.now + 6.hours, total_hours: 6.0, parent_id: attendance_1.id}

    context 'find last entry from multiple checkin' do
      it 'returns last checkin' do
        attendance = Attendance.find_last_entry(user.id, Date.today)
        expect(attendance.parent_id).to eq(attendance_1.id)
      end
    end
  end

end