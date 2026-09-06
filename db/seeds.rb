# Default seeds for development environment

puts "== Seeding Master Data =="

leave_year = LeaveYear.find_or_create_by(year: Date.today.year.to_s) do |ly|
  ly.present = true
end

if HolidayScheme.count.zero?
  HolidayScheme.create([
    { name: 'Nascenia General', active: true, leave_year_id: leave_year.id },
    { name: 'GJ and Biyeta', active: true, leave_year_id: leave_year.id }
  ])
end
holiday_scheme = HolidayScheme.first

if Weekend.count.zero?
  Weekend.create([
    { name: 'Nascenia Core: Sat & Sun', off_days: [:saturday, :sunday] },
    { name: 'Admin: Sat', off_days: [:saturday] },
    { name: 'Biyeta: Thu & Fri', off_days: [:thursday, :friday] }
  ])
end
weekend = Weekend.first

if Designation.count.zero?
  Designation.create([
    { team: 'Developer', title: 'Intern', description: 'Internship', published: true },
    { team: 'Developer', title: 'Junior Software Engineer', description: 'Junior software engineer', published: true },
    { team: 'Developer', title: 'Software Engineer', description: 'Software engineer', published: true },
    { team: 'Developer', title: 'Senior Software Engineer', description: 'Senior software engineer', published: true }
  ])
end
designation = Designation.published.first

if GoalCategory.count.zero?
  GoalCategory.create([
    { title: 'Technical asset development', description: '', published: true },
    { title: 'Develop skills',              description: '', published: true },
    { title: 'Technical session',           description: '', published: true }
  ])
end

approval_path = ApprovalPath.find_or_create_by(name: 'Default Approval Path')

puts "== Seeding Admin Users =="

# 1. ActiveAdmin user (admin@example.com)
admin_au = AdminUser.find_or_initialize_by(email: 'admin@example.com')
admin_au.password = 'password123'
admin_au.password_confirmation = 'password123'
admin_au.save!

# 2. Main Application Admin User (admin@example.com)
app_admin = User.find_or_initialize_by(email: 'admin@example.com')
app_admin.assign_attributes(
  name: 'System Admin',
  password: 'password123',
  password_confirmation: 'password123',
  role: User::SUPER_TTF,
  is_active: true,
  is_published: true,
  approval_path_id: approval_path.id,
  weekend_id: weekend.id,
  holiday_scheme_id: holiday_scheme.id,
  personal_email: 'admin@example.com',
  mobile_number: '01700000000',
  joining_date: Date.today,
  registration_status: User::REGISTRATION_STATUS[:registered],
  employee_id: 'A1000'
)
app_admin.save!

# 3. Super Admin User (reyanus@nascenia.com)
super_admin_au = AdminUser.find_or_initialize_by(email: 'reyanus@nascenia.com')
super_admin_au.password = 'password123'
super_admin_au.password_confirmation = 'password123'
super_admin_au.save!

super_admin = User.find_or_initialize_by(email: 'reyanus@nascenia.com')
super_admin.name ||= 'Reyanus Salehin'
super_admin.role = User::SUPER_TTF
super_admin.is_active = true
super_admin.is_published = true
if super_admin.new_record?
  super_admin.password = 'password123'
  super_admin.password_confirmation = 'password123'
  super_admin.approval_path_id = approval_path.id
  super_admin.weekend_id = weekend.id
  super_admin.holiday_scheme_id = holiday_scheme.id
  super_admin.personal_email = 'salehin24.rs@gmail.com'
  super_admin.mobile_number = '01608537383'
  super_admin.joining_date = Date.today
  super_admin.registration_status = User::REGISTRATION_STATUS[:registered]
  super_admin.employee_id = 'A2300'
end
super_admin.save!

puts "== Seeding TTF Facilitator =="

ttf_user = User.find_or_initialize_by(email: 'ttf1@nascenia.com')
ttf_user.assign_attributes(
  name: 'TTF Facilitator',
  password: 'password123',
  password_confirmation: 'password123',
  role: User::TTF,
  is_active: true,
  is_published: true,
  approval_path_id: approval_path.id,
  weekend_id: weekend.id,
  holiday_scheme_id: holiday_scheme.id,
  personal_email: 'ttf1@personal.com',
  mobile_number: '01710000001',
  joining_date: Date.today,
  registration_status: User::REGISTRATION_STATUS[:registered],
  employee_id: 'A2001'
)
ttf_user.save!

puts "== Seeding Whitelisted Emails for Google OAuth =="

['reyanus.nascenia@gmail.com', 'a2i.chatbot.2023@gmail.com', 'salehin24.rs@gmail.com'].each do |gmail|
  we = WhitelistEmail.find_or_initialize_by(email: gmail)
  we.published = true
  we.save!
  puts "Whitelisted Google email: #{gmail}"
end

puts "== Cleaning Up Any Existing Test Users =="

test_emails = [
  'reyanus.nascenia+5@nascenia.com',
  'reyanus@nasceia.com',
  'reyanus.nascenia@gmail.com',
  'salehin24.rs@gmail.com',
  'a2i.chatbot.2023@gmail.com'
]

test_emails.each do |email|
  existing_user = User.find_by(email: email)
  if existing_user
    puts "Deleting existing test user: #{email}"
    existing_user.destroy
  end
end

# Clean up old test pre-registrations to avoid uniqueness collisions
PreRegistration.where(employee_id: ['Z1001', 'G1001', 'N1001']).destroy_all
PreRegistration.where(companyEmail: test_emails).destroy_all

puts "== Seeding 3 Pre-registrations for Testing Onboarding (step_no: 2) =="

test_onboarding_candidates = [
  {
    employee_id: 'Z1001',
    name: 'Reyanus Zoho',
    companyEmail: 'reyanus.nascenia@gmail.com',
    personalEmail: 'reyanus.nascenia@gmail.com',
    contactNumber: '01711111111',
    scenario: 'Zoho Email Account'
  },
  {
    employee_id: 'G1001',
    name: 'Salehin Gmail',
    companyEmail: 'salehin24.rs@gmail.com',
    personalEmail: 'salehin24.rs@gmail.com',
    contactNumber: '01722222222',
    scenario: 'Gmail Account'
  },
  {
    employee_id: 'N1001',
    name: 'A2I Chatbot Neither',
    companyEmail: 'a2i.chatbot.2023@gmail.com',
    personalEmail: 'a2i.chatbot.2023@gmail.com',
    contactNumber: '01733333333',
    scenario: 'Neither Zoho nor Gmail'
  }
]

test_onboarding_candidates.each do |cand|
  pr = PreRegistration.find_or_initialize_by(employee_id: cand[:employee_id])
  pr.assign_attributes(
    name: cand[:name],
    joiningDate: Date.today.strftime('%Y/%m/%d'),
    designation: designation ? designation.title : 'Software Engineer',
    personalEmail: cand[:personalEmail],
    companyEmail: cand[:companyEmail],
    contactNumber: cand[:contactNumber],
    emailGroup: 'dev@nascenia.com',
    HR_email: 'hr@nascenia.com',
    holiday_scheme_id: holiday_scheme.id.to_s,
    weekend_id: weekend.id.to_s,
    ttf_id: ttf_user.id,
    leave_approval_path_id: approval_path.id,
    NdaSigned: true,
    workstationReady: true,
    packReady: true,
    user_id: nil,
    step_no: 2
  )
  pr.save!
  puts "Seeded PreRegistration [#{cand[:scenario]}]: #{pr.employee_id} - #{pr.companyEmail} (ID: #{pr.id}, step: #{pr.step_no})"
end

puts "== Seeding Complete! =="
