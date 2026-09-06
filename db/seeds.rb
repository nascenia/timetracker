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

# ActiveAdmin Admin Users
admin_user = AdminUser.find_or_initialize_by(email: 'admin@example.com')
admin_user.password = 'password'
admin_user.password_confirmation = 'password'
admin_user.save!

super_admin_au = AdminUser.find_or_initialize_by(email: 'reyanus_5@nascenia.com')
super_admin_au.password = 'r1124.S@nas.com'
super_admin_au.password_confirmation = 'r1124.S@nas.com'
super_admin_au.save!

# Main Application Admin User (reyanus_5@nascenia.com)
app_admin = User.find_or_initialize_by(email: 'reyanus_5@nascenia.com')
app_admin.assign_attributes(
  name: 'Reyanus Salehin',
  password: 'r1124.S@nas.com',
  password_confirmation: 'r1124.S@nas.com',
  role: 3,
  is_active: true,
  is_published: true,
  approval_path_id: approval_path.id,
  weekend_id: weekend.id,
  holiday_scheme_id: holiday_scheme.id,
  personal_email: 'salehin24.rs@gmail.com',
  present_address: '123, Some Street, Some City',
  alternate_contact: '01608537383',
  permanent_address: '456, Another Street, Another City',
  mobile_number: '01608537383',
  date_of_birth: '2001-11-24',
  last_degree: 'B.Sc. in Computer Science',
  last_university: 'Islamic University of Technology',
  passing_year: '2023',
  emergency_contact_person_name: 'John Doe',
  emergency_contact_person_relation: 'Brother',
  emergency_contact_person_number: '01723456789',
  blood_group: 'O+',
  joining_date: Date.parse('2025-07-10'),
  registration_status: 2,
  national_id: '1514947595',
  employee_id: 'A2300'
)
app_admin.save!

# PreRegistration for Super Admin
admin_pr = PreRegistration.find_or_initialize_by(employee_id: 'A2300')
admin_pr.assign_attributes(
  name: 'Reyanus Salehin',
  joiningDate: '2025-07-10',
  personalEmail: 'salehin24.rs@gmail.com',
  companyEmail: 'reyanus_5@nascenia.com',
  contactNumber: '01608537383',
  designation: 'Software Engineer',
  step_no: 3,
  leave_approval_path_id: approval_path.id,
  weekend_id: weekend.id,
  holiday_scheme_id: holiday_scheme.id,
  ttf_id: app_admin.id,
  workstationReady: true,
  packReady: true,
  emailGroup: 'admins@nascenia.com',
  HR_email: 'hr@nascenia.com',
  NdaSigned: true,
  user_id: app_admin.id
)
admin_pr.save!

puts "== Seeding TTF and Developer Users =="

# TTF User
ttf_user = User.find_or_initialize_by(email: 'ttf1@nascenia.com')
ttf_user.assign_attributes(
  name: 'TTF 1',
  password: 'password123',
  password_confirmation: 'password123',
  role: User::TTF,
  is_active: true,
  is_published: true,
  approval_path_id: approval_path.id,
  weekend_id: weekend.id,
  holiday_scheme_id: holiday_scheme.id,
  personal_email: 'ttf1@personal.com',
  mobile_number: '0171000001',
  joining_date: Date.today,
  registration_status: User::REGISTRATION_STATUS[:registered],
  employee_id: 'A2001'
)
ttf_user.save!

ttf_pr = PreRegistration.find_or_initialize_by(employee_id: 'A2001')
ttf_pr.assign_attributes(
  name: 'TTF 1',
  joiningDate: Date.today.strftime('%Y/%m/%d'),
  personalEmail: 'ttf1@personal.com',
  companyEmail: 'ttf1@nascenia.com',
  contactNumber: '0171000001',
  designation: 'Team Technical Facilitator',
  step_no: 3,
  leave_approval_path_id: approval_path.id,
  weekend_id: weekend.id,
  holiday_scheme_id: holiday_scheme.id,
  ttf_id: ttf_user.id,
  workstationReady: true,
  packReady: true,
  emailGroup: 'ttf1@nascenia.com',
  HR_email: 'hr@nascenia.com',
  NdaSigned: true,
  user_id: ttf_user.id
)
ttf_pr.save!

# Developer User
dev_user = User.find_or_initialize_by(email: 'dev1@nascenia.com')
dev_user.assign_attributes(
  name: 'Developer 1',
  password: 'password123',
  password_confirmation: 'password123',
  role: User::EMPLOYEE,
  is_active: true,
  is_published: true,
  approval_path_id: approval_path.id,
  weekend_id: weekend.id,
  holiday_scheme_id: holiday_scheme.id,
  personal_email: 'dev1@personal.com',
  mobile_number: '0181000001',
  joining_date: Date.today,
  registration_status: User::REGISTRATION_STATUS[:registered],
  employee_id: 'A2002',
  ttf_id: ttf_user.id
)
dev_user.save!

puts "== Seeding Pre-registrations for Testing Onboarding (step_no: 2) =="

onboarding_employees = [
  {
    employee_id: 'T1001',
    name: 'Test Zoho Employee',
    personalEmail: 'zoho_employee@personal.com',
    companyEmail: 'test_zoho_emp@nascenia.com',
    contactNumber: '01711111111'
  },
  {
    employee_id: 'T1002',
    name: 'Test Gmail Employee',
    personalEmail: 'gmail_employee@personal.com',
    companyEmail: 'test_gmail_emp@nascenia.com',
    contactNumber: '01722222222'
  },
  {
    employee_id: 'T1003',
    name: 'Test Neither Employee',
    personalEmail: 'neither_employee@personal.com',
    companyEmail: 'test_neither_emp@nascenia.com',
    contactNumber: '01733333333'
  }
]

onboarding_employees.each do |data|
  pr = PreRegistration.find_or_initialize_by(employee_id: data[:employee_id])
  pr.assign_attributes(
    name: data[:name],
    joiningDate: Date.today.strftime('%Y/%m/%d'),
    designation: designation ? designation.title : 'Software Engineer',
    personalEmail: data[:personalEmail],
    companyEmail: data[:companyEmail],
    contactNumber: data[:contactNumber],
    emailGroup: 'dev@nascenia.com',
    HR_email: 'hr@nascenia.com',
    holiday_scheme_id: holiday_scheme.id.to_s,
    weekend_id: weekend.id.to_s,
    ttf_id: ttf_user.id,
    leave_approval_path_id: approval_path.id,
    NdaSigned: true,
    workstationReady: true,
    packReady: true,
    step_no: 2
  )
  pr.save!
  puts "Seeded PreRegistration #{pr.employee_id}: #{pr.name} (step_no: 2)"
end

puts "== Seeding Complete! =="
