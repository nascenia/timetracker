require 'rails_helper'

RSpec.describe PreRegistration, type: :model do
  describe 'email account accessors' do
    it 'supports zoho_email_account and gmail_email_account accessors' do
      pr = PreRegistration.new
      pr.zoho_email_account = '1'
      pr.gmail_email_account = '0'
      expect(pr.zoho_email_account).to eq('1')
      expect(pr.gmail_email_account).to eq('0')
    end
  end

  describe 'UserMailer onboarding email URL generation' do
    before(:all) do
      ActionMailer::Base.default_url_options = { host: 'localhost', port: 3000 }
    end

    let(:pre_registration) do
      PreRegistration.new(
        name: 'John Doe',
        companyEmail: 'john.doe@nascenia.com',
        employee_id: 'J1001'
      )
    end

    it 'generates sign_in (login) url and wording when gmail is checked' do
      mail = UserMailer.send_mail_to_new_employee_about_tt(pre_registration, '0', '1')
      mail.deliver
      sent = ActionMailer::Base.deliveries.last
      expect(sent.body.raw_source).to include('http://localhost:3000/users/sign_in')
      expect(sent.body.raw_source).not_to include('http://localhost:3000/users/sign_up')
      expect(sent.body.raw_source).to include('Please go to the link below and log in with your new email address:')
      expect(sent.body.raw_source).not_to include('sign up with your new email address:')
    end

    it 'generates sign_up url and wording with email prefilled when zoho is checked' do
      mail = UserMailer.send_mail_to_new_employee_about_tt(pre_registration, '1', '0')
      mail.deliver
      sent = ActionMailer::Base.deliveries.last
      expect(sent.body.raw_source).to include('http://localhost:3000/users/sign_up?email=john.doe%40nascenia.com')
      expect(sent.body.raw_source).not_to include('http://localhost:3000/users/sign_in')
      expect(sent.body.raw_source).to include('Please go to the link below and sign up with your new email address:')
      expect(sent.body.raw_source).not_to include('log in with your new email address:')
    end

    it 'generates sign_up url and wording with email prefilled when neither is checked' do
      mail = UserMailer.send_mail_to_new_employee_about_tt(pre_registration, '0', '0')
      mail.deliver
      sent = ActionMailer::Base.deliveries.last
      expect(sent.body.raw_source).to include('http://localhost:3000/users/sign_up?email=john.doe%40nascenia.com')
      expect(sent.body.raw_source).not_to include('http://localhost:3000/users/sign_in')
      expect(sent.body.raw_source).to include('Please go to the link below and sign up with your new email address:')
      expect(sent.body.raw_source).not_to include('log in with your new email address:')
    end

    it 'delivers to both companyEmail and personalEmail when personalEmail is present' do
      pre_registration.personalEmail = 'john.doe@personal.com'
      mail = UserMailer.send_mail_to_new_employee_about_tt(pre_registration, '1', '0')
      mail.deliver
      sent = ActionMailer::Base.deliveries.last
      expect(sent.to).to include('john.doe@nascenia.com')
      expect(sent.to).to include('john.doe@personal.com')
    end

    it 'ensures generated urls are absolute and do not contain relative-only paths' do
      mail = UserMailer.send_mail_to_new_employee_about_tt(pre_registration, '1', '0')
      mail.deliver
      sent = ActionMailer::Base.deliveries.last
      expect(sent.body.raw_source).not_to match(/href="\/users\//)
      expect(sent.body.raw_source).to match(/href="http:\/\/localhost:3000\/users\//)
    end
  end

  describe 'User sign-up validations' do
    it 'validates presence of email' do
      user = User.new(email: '', password: 'password123', password_confirmation: 'password123')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'validates format of email' do
      user = User.new(email: 'not-an-email', password: 'password123', password_confirmation: 'password123')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("is invalid")
    end

    it 'validates presence of password' do
      user = User.new(email: 'valid@example.com', password: '', password_confirmation: '')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("can't be blank")
    end

    it 'validates minimum length of password to be 8 characters' do
      user = User.new(email: 'valid@example.com', password: 'short', password_confirmation: 'short')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("is too short (minimum is 8 characters)")
    end

    it 'validates password confirmation matches password' do
      user = User.new(email: 'valid@example.com', password: 'password123', password_confirmation: 'different123')
      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to include("doesn't match Password")
    end
  end
end
