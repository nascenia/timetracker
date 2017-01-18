require 'rails_helper'

RSpec.describe Leave, type: :model do

  describe 'associations' do
    it 'should belong to user' do
      leave = Leave.reflect_on_association(:user)

      expect(leave.macro).to eq(:belongs_to)
      expect(leave.name).to eq(:user)
    end
  end

  describe 'validations' do
    it 'should represent casual type' do
      expect(Leave::CASUAL).to eq(1)
    end

    it 'should represent medical type' do
      expect(Leave::MEDICAL).to eq(2)
    end

    it 'should represent unannounced type' do
      expect(Leave::UNANNOUNCED).to eq(3)
    end

    it 'should define casual leave' do
      expect(Leave::LEAVE_TYPES[0][0]).to eq('Casual Leave')
      expect(Leave::LEAVE_TYPES[0][1]).to eq(1)
    end

    it 'should define medical leave' do
      expect(Leave::LEAVE_TYPES[1][0]).to eq('Medical Leave')
      expect(Leave::LEAVE_TYPES[1][1]).to eq(2)
    end

    it 'should represent accepted state' do
      expect(Leave::ACCEPTED).to eq(1)
    end

    it 'should represent rejected state' do
      expect(Leave::REJECTED).to eq(2)
    end

    it 'should represent pending state' do
      expect(Leave::PENDING).to eq(3)
    end

    it 'should represent one day office hours' do
      expect(Leave::HOURS_FOR_ONE_DAY).to eq(8)
    end

    it 'should represent half day office hours' do
      expect(Leave::HOURS_FOR_HALF_DAY).to eq(4)
    end

    it 'should represent leave approved status' do
      expect(Leave::LEAVE_STATUSES[0][0]).to eq('Approved')
      expect(Leave::LEAVE_STATUSES[0][1]).to eq(1)
    end

    it 'should represent leave rejected status' do
      expect(Leave::LEAVE_STATUSES[1][0]).to eq('Rejected')
      expect(Leave::LEAVE_STATUSES[1][1]).to eq(2)
    end

    it 'should represent leave pending status' do
      expect(Leave::LEAVE_STATUSES[2][0]).to eq('Pending')
      expect(Leave::LEAVE_STATUSES[2][1]).to eq(3)
    end
  end

  describe 'is_pending?' do
    let(:user) { create :user, email: 'khalid@nascenia.com' }
    let(:leave1) { create :leave, user_id: user.id }
    let(:leave2) { create :leave, user_id: user.id, status: LEAVE[:PENDING] }

    it 'should return false if leave status is not pending' do
      expect(leave1.is_pending?).to eq(false)
    end
    it 'should return true if leave status is pending' do
      expect(leave2.is_pending?).to eq(true)
    end
  end

  describe 'is_accepted?' do
    let(:user) { create  :user, email: 'test1@nascenia.com' }
    let(:leave1) { create :leave, user_id: user.id }
    let(:leave2) { create :leave, user_id: user.id, status: LEAVE[:ACCEPTED] }

    it 'should return false if leave status is not accepted' do
      expect(leave1.is_accepted?).to eq(false)
    end
    it 'should return true if leave status is accepted' do
      expect(leave2.is_accepted?).to eq(true)
    end
  end

  describe 'is_rejected?' do
    let(:user) { create :user, email: 'test2@nascenia.com' }
    let(:leave1) { create :leave, user_id: user.id }
    let(:leave2) { create :leave, user_id: user.id, status: LEAVE[:REJECTED] }

    it 'should return false if leave status is not rejected' do
      expect(leave1.is_rejected?).to eq(false)
    end
    it 'should return true if leave status is rejected' do
      expect(leave2.is_rejected?).to eq(true)
    end
  end

end