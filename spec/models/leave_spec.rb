require 'rails_helper'

RSpec.describe Leave, type: :model do

  describe 'associations' do
    it 'should belong to user' do
      leave = Leave.reflect_on_association(:user)

      expect(leave.macro).to eq(:belongs_to)
      expect(leave.name).to eq(:user)
    end
  end

  LEAVE = {
    CASUAL: 1,
    MEDICAL: 2,
    UNANNOUNCED: 3,

    LEAVE_TYPES: [
      ['Casual Leave', 1],
      ['Medical Leave', 2]
    ],

    ACCEPTED: 1,
    REJECTED: 2,
    PENDING: 3,

    HOURS_FOR_ONE_DAY: 8,
    HOURS_FOR_HALF_DAY: 4,

    LEAVE_STATUSES: [
      ['Approved', 1],
      ['Rejected', 2],
      ['Pending', 3]
    ]
  }

  describe 'validations' do
    it 'should represent casual type' do
      expect(Leave::CASUAL).to eq(LEAVE[:CASUAL])
    end

    it 'should represent medical type' do
      expect(Leave::MEDICAL).to eq(LEAVE[:MEDICAL])
    end

    it 'should represent unannounced type' do
      expect(Leave::UNANNOUNCED).to eq(LEAVE[:UNANNOUNCED])
    end

    it 'should define casual leave' do
      expect(Leave::LEAVE_TYPES[0][0]).to eq(LEAVE[:LEAVE_TYPES][0][0])
      expect(Leave::LEAVE_TYPES[0][1]).to eq(LEAVE[:LEAVE_TYPES][0][1])
    end

    it 'should define medical leave' do
      expect(Leave::LEAVE_TYPES[1][0]).to eq(LEAVE[:LEAVE_TYPES][1][0])
      expect(Leave::LEAVE_TYPES[1][1]).to eq(LEAVE[:LEAVE_TYPES][1][1])
    end

    it 'should represent accepted state' do
      expect(Leave::ACCEPTED).to eq(LEAVE[:ACCEPTED])
    end

    it 'should represent rejected state' do
      expect(Leave::REJECTED).to eq(LEAVE[:REJECTED])
    end

    it 'should represent pending state' do
      expect(Leave::PENDING).to eq(LEAVE[:PENDING])
    end

    it 'should represent one day office hours' do
      expect(Leave::HOURS_FOR_ONE_DAY).to eq(LEAVE[:HOURS_FOR_ONE_DAY])
    end

    it 'should represent half day office hours' do
      expect(Leave::HOURS_FOR_HALF_DAY).to eq(LEAVE[:HOURS_FOR_HALF_DAY])
    end

    it 'should represent leave approved status' do
      expect(Leave::LEAVE_STATUSES[0][0]).to eq(LEAVE[:LEAVE_STATUSES][0][0])
      expect(Leave::LEAVE_STATUSES[0][1]).to eq(LEAVE[:LEAVE_STATUSES][0][1])
    end

    it 'should represent leave rejected status' do
      expect(Leave::LEAVE_STATUSES[1][0]).to eq(LEAVE[:LEAVE_STATUSES][1][0])
      expect(Leave::LEAVE_STATUSES[1][1]).to eq(LEAVE[:LEAVE_STATUSES][1][1])
    end

    it 'should represent leave pending status' do
      expect(Leave::LEAVE_STATUSES[2][0]).to eq(LEAVE[:LEAVE_STATUSES][2][0])
      expect(Leave::LEAVE_STATUSES[2][1]).to eq(LEAVE[:LEAVE_STATUSES][2][1])
    end
  end

  # TODO: leave tracker related features are not yet full functional,
  # TODO: first this have to be implemented then test code should be updated
  describe 'update_leave_tracker' do
    let(:user) { create :user, email: 'khalid@nascenia.com' }
    let(:leave) { create :leave, user_id: user.id }

    it 'should update leave tracker' do
      # leave.update_leave_tracker
      # expect('a').to eq('a')
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