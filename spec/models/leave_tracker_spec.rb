require 'rails_helper'

RSpec.describe LeaveTracker, type: :model do

  describe 'associations' do
    it 'should belong to user' do
      leave_tracker = LeaveTracker.reflect_on_association(:user)

      expect(leave_tracker.macro).to eq(:belongs_to)
      expect(leave_tracker.name).to eq(:user)
    end

    it 'should belong to leave' do
      leave_tracker = LeaveTracker.reflect_on_association(:leave)

      expect(leave_tracker.macro).to eq(:belongs_to)
      expect(leave_tracker.name).to eq(:leave)
    end

  end

  LEAVE_TRACKER = {
    YEARLY_CASUAL_LEAVE: 80,
    YEARLY_MEDICAL_LEAVE: 48,
    CASUAL_LEAVE_IN_DAYS: 10,
    MEDICAL_LEAVE_IN_DAYS: 6
  }

  describe 'validations' do
    it 'should define yearly casual leave' do
      expect(LeaveTracker::YEARLY_CASUAL_LEAVE).to eq(LEAVE_TRACKER[:YEARLY_CASUAL_LEAVE])
    end

    it 'should define yearly medical leave' do
      expect(LeaveTracker::YEARLY_MEDICAL_LEAVE).to eq(LEAVE_TRACKER[:YEARLY_MEDICAL_LEAVE])
    end

    it 'should define casual leave in days' do
      expect(LeaveTracker::CASUAL_LEAVE_IN_DAYS).to eq(LEAVE_TRACKER[:CASUAL_LEAVE_IN_DAYS])
    end

    it 'should define medical leave in days' do
      expect(LeaveTracker::MEDICAL_LEAVE_IN_DAYS).to eq(LEAVE_TRACKER[:MEDICAL_LEAVE_IN_DAYS])
    end

  end

  let!(:user) { create :user, email: 'khalid@nascenia.com' }

  describe '#populate_with_default_yearly_leave' do
    it 'should update default yearly leave' do
      LeaveTracker.populate_with_default_yearly_leave
      expect(LeaveTracker.all.size).to eq(User.active.all.size)
    end
  end

  # describe 'create_leave_tracker' do
  #   let(:user) { create :user, email: 'khalid@nascenia.com' }
  #   let(:leave) { create :leave, user_id: user.id }
  #
  #   it 'should update leave tracker' do
  #     leave.update_leave_tracker
  #     # expect('a').to eq('a')
  #   end
  # end

  describe '#populate_with_commenced_date' do
    let!(:leave_tracker) { create :leave_tracker, user_id: user.id }
    it 'should update commenced date' do
      LeaveTracker.populate_with_commenced_date
      expect(user.leave_tracker.commenced_date).to eq(Time.now.at_beginning_of_year)
    end
  end

  describe '#populate_with_carried_forward_leave' do
    let!(:leave_tracker) { create :leave_tracker, user_id: user.id,
                                  accrued_vacation_balance: 100,
                                  accrued_medical_balance: -100 }
    it 'should update carried forward leave' do
      LeaveTracker.populate_with_carried_forward_leave
      expect(user.leave_tracker.carried_forward_vacation).to eq(80)
      expect(user.leave_tracker.carried_forward_medical).to eq(-100)
    end
  end

  describe '#populate_with_consumed_leave' do
    let!(:leave_tracker) { create :leave_tracker, user_id: user.id }
    it 'should update consumed leave' do
      LeaveTracker.populate_with_consumed_leave
      expect(user.leave_tracker.consumed_vacation).to eq(0)
      expect(user.leave_tracker.consumed_medical).to eq(0)
    end
  end

  describe 'update_leave_tracker_daily' do
    let!(:leave_tracker) { create :leave_tracker, user_id: user.id,
                                  commenced_date: Time.now - 20.days,
                                  consumed_vacation: 2, consumed_medical: 2 }
    it 'should update daily leave tracker' do
      leave_tracker.update_leave_tracker_daily
      expect(user.leave_tracker.accrued_vacation_this_year).to eq(((((Time.now.to_date - leave_tracker.commenced_date.to_date).to_i) * LeaveTracker::CASUAL_LEAVE_IN_DAYS/365.0) * 8).to_i)
    end
  end

end