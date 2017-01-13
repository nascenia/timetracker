require 'rails_helper'

RSpec.describe User, type: :model do

  describe 'associations' do
    it 'should has many attendances' do
      u = User.reflect_on_association(:attendances)

      expect(u.macro).to eq(:has_many)
      expect(u.name).to eq(:attendances)
    end

    it 'should has many leave' do
      u = User.reflect_on_association(:leave)

      expect(u.macro).to eq(:has_many)
      expect(u.name).to eq(:leave)
    end

    it 'should have one leave tracker' do
      u = User.reflect_on_association(:leave_tracker)

      expect(u.macro).to eq(:has_one)
      expect(u.name).to eq(:leave_tracker)
    end
  end

  describe 'validations' do
    it 'should be invalid if email not present' do
      expect(build(:user, email: nil)).to_not be_valid
    end

    it 'should be invalid if password not present' do
      expect(build(:user, password: nil)).to_not be_valid
    end
  end

  describe 'is_admin?' do
    let(:user) { create :user, email: 'khalid@nascenia.com' }

    context 'when user is admin' do
      it 'should return true' do
        expect(user.is_admin?).to eq(true)
      end
    end

    context 'when user is not admin' do
      it 'should return false' do
        user.email = 'example@email.com'
        expect(user.is_admin?).to eq(false)
      end
    end
  end

  describe 'is_ttf?' do

    context 'when user is ttf' do
      let(:user) { create :user, role: User::TTF }
      it 'should return true' do
        expect(user.is_ttf?).to eq(true)
      end
    end

    context 'when user is not ttf' do
      let(:user) { create :user }
      it 'should return false' do
        expect(user.is_ttf?).to eq(false)
      end
    end
  end

  describe 'is_super_ttf?' do

    context 'when user is super ttf' do
      let(:user){create :user, role: User::SUPER_TTF}
      it 'should return true' do
        expect(user.is_super_ttf?).to eq(true)
      end
    end

    context 'wher user is not super ttf' do
      let(:user){create :user}
      it 'should return false' do
        expect(user.is_super_ttf?).to eq(false)
      end
    end
  end

  describe 'create_attendance' do
    let(:user){create :user}
    it 'should create new attendance' do
      user.create_attendance
      user.create_attendance
      expect(user.attendances.count).to eq(Attendance.where(user_id: user.id).count)
    end
  end

  describe 'has_applied_for_leave' do

    context 'when leave is accpeted' do
      let(:leave){create :leave, start_date: Time.now.to_date, status: Leave::ACCEPTED}
      let(:user){create :user, leave: [leave]}
      it 'should return true' do
        expect(user.has_applied_for_leave).to eq(true)
      end
    end

    context 'when leave is not accpeted' do
      let(:leave){create :leave, start_date: Time.now.to_date, status: Leave::REJECTED}
      let(:user){create :user, leave: [leave]}
      it 'should return false' do
        expect(user.has_applied_for_leave).to eq(false)
      end
    end
  end
end