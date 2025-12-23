# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#Salaat.create(waqt: 'Zohr', time: '1:30')
#Salaat.create(waqt: 'Asor', time: '4:15')
#Salaat.create(waqt: 'Magrib', time: '5:30')

if HolidayScheme.count.zero?
  HolidayScheme.create([
    { name: 'Nascenia General', active: true, leave_year_id: 1 },
    { name: 'GJ and Biyeta', active: true, leave_year_id: 1 },
  ])
end

if Weekend.count.zero?
  Weekend.create([
    { name: 'Nascenia Core: Sat & Sun', off_days: [:saturday, :sunday] },
    { name: 'Admin: Sat', off_days: [:saturday] },
    { name: 'Biyeta: Thu & Fri', off_days: [:thursday, :friday] }
  ])
end

if LeaveYear.count.zero?
  p 'Creating LeaveYear...'
  LeaveYear.find_or_create_by(year: Date.today.year.to_s, present: true)
end

if Designation.count.zero?
  p 'Creating employee designations...'
  Designation.create([
    { team: 'Developer', title: 'Intern', description: 'Internship', published: true },
    { team: 'Developer', title: 'Junior Software Engineer', description: 'Junior software engineer', published: true },
    { team: 'Developer', title: 'Software Engineer', description: 'Software engineer', published: true },
    { team: 'Developer', title: 'Senior Software Engineer', description: 'Senior software engineer', published: true }
  ])
end

if GoalCategory.count.zero?
  p 'Creating goal categories...'
  GoalCategory.create([
    { title: 'Technical asset development', description: '', published: true },
    { title: 'Develop skills',              description: '', published: true },
    { title: 'Technical session',           description: '', published: true }
  ])
  p 'Done'
end

# -------- create Admin --------
AdminUser.find_or_create_by!(email: "reyanus_5@nascenia.com") do |admin|
  admin.password = "r1124.S@nas.com"
  admin.password_confirmation = "r1124.S@nas.com"
end

PreRegistration.find_or_create_by!(companyEmail: "reyanus_5@nascenia.com") do |pr|
  pr.name = "Reyanus Salehin"
  pr.employee_id = "A2300"
  pr.joiningDate = Date.parse("2025-07-10")
  pr.personalEmail = "salehin24.rs@gmail.com"
  pr.contactNumber = "01608537383"
  pr.designation = "Software Engineer"
  pr.step_no = 1
  pr.leave_approval_path_id = ApprovalPath.first ? ApprovalPath.first.id : 1
  pr.weekend_id = Weekend.first ? Weekend.first.id : 1
  pr.holiday_scheme_id = HolidayScheme.first ? HolidayScheme.first.id : 1
  pr.ttf_id = "A2300"
  pr.workstationReady = true
  pr.packReady = true
  pr.emailGroup = "admins@nascenia.com"
  pr.ndaDoc = "nda_document.pdf"
  pr.HR_email = "hr@nascenia.com"
end

User.find_or_create_by!(email: "reyanus_5@nascenia.com") do |u|
  u.name = "Reyanus Salehin"
  u.email = "reyanus_5@nascenia.com"
  u.password = "r1124.S@nas.com"
  u.password_confirmation = "r1124.S@nas.com"
  u.role = 3
  u.is_active = true
  u.is_published = true
  u.approval_path_id = ApprovalPath.first ? ApprovalPath.first.id : 1
  u.weekend_id = Weekend.first ? Weekend.first.id : 1
  u.holiday_scheme_id = HolidayScheme.first ? HolidayScheme.first.id : 1
  u.personal_email = "salehin24.rs@gmail.com"
  u.present_address = "123, Some Street, Some City"
  u.alternate_contact = "01608537383"
  u.permanent_address = "456, Another Street, Another City"
  u.mobile_number = "01608537383"
  u.date_of_birth = "2001-11-24"
  u.last_degree = "B.Sc. in Computer Science"
  u.last_university = "Islamic University of Technology"
  u.passing_year = "2023"
  u.emergency_contact_person_name = "John Doe"
  u.emergency_contact_person_relation = "Brother"
  u.emergency_contact_person_number = "01723456789"
  u.blood_group = "O+"
  u.joining_date = Date.parse("2025-07-10")
  u.registration_status = 2
  u.national_id = "1514947595"
  u.employee_id = "A2300"
  u.kpi_template_id = nil
end

approval_path   = ApprovalPath.first || ApprovalPath.create!(name: 'Default Approval Path')
weekend         = Weekend.first
holiday_scheme  = HolidayScheme.first

def generate_employee_id(counter)
  "A#{(2000 + counter).to_s.rjust(4, '0')}"
end

employee_counter = 1

# -------- create TTF --------
ttf_employee_id = generate_employee_id(employee_counter)

ttf_pr = PreRegistration.find_or_create_by!(companyEmail: "ttf1@nascenia.com") do |pr|
  pr.name = "TTF 1"
  pr.employee_id = ttf_employee_id
  pr.joiningDate = Date.today
  pr.personalEmail = "ttf1@personal.com"
  pr.contactNumber = "0171000001"
  pr.designation = "Team Technical Facilitator"
  pr.step_no = 1
  pr.leave_approval_path_id = approval_path.id
  pr.weekend_id = weekend.id
  pr.holiday_scheme_id = holiday_scheme.id
  pr.ttf_id = ttf_employee_id
  pr.workstationReady = true
  pr.packReady = true
  pr.emailGroup = "ttf1@nascenia.com"
  pr.ndaDoc = "nda_document.pdf"
  pr.HR_email = "hr@nascenia.com"
end

ttf_user = User.find_or_create_by!(email: "ttf1@nascenia.com") do |u|
  u.name = "TTF 1"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = User::TTF
  u.is_active = true
  u.is_published = true
  u.approval_path_id = approval_path.id
  u.weekend_id = weekend.id
  u.holiday_scheme_id = holiday_scheme.id
  u.personal_email = "ttf1@personal.com"
  u.mobile_number = "0171000001"
  u.joining_date = Date.today
  u.registration_status = User::REGISTRATION_STATUS[:registered]
  u.employee_id = ttf_employee_id
end

puts "TTF User DB ID: #{ttf_user.id}"


employee_counter += 1

# -------- create Developer --------
dev_employee_id = generate_employee_id(employee_counter)

dev_pr = PreRegistration.find_or_create_by!(companyEmail: "dev1@nascenia.com") do |pr|
  pr.name = "Developer 1"
  pr.employee_id = dev_employee_id
  pr.joiningDate = Date.today
  pr.personalEmail = "dev1@personal.com"
  pr.contactNumber = "0181000001"
  pr.designation = "Software Engineer"
  pr.step_no = 1
  pr.leave_approval_path_id = approval_path.id
  pr.weekend_id = weekend.id
  pr.holiday_scheme_id = holiday_scheme.id
  pr.ttf_id = ttf_employee_id
  pr.workstationReady = true
  pr.packReady = true
  pr.emailGroup = "dev1@nascenia.com"
  pr.ndaDoc = "nda_document.pdf"
  pr.HR_email = "hr@nascenia.com"
end

dev_user = User.find_or_create_by!(email: "dev1@nascenia.com") do |dev|
  dev.name = "Developer 1"
  dev.password = "password123"
  dev.password_confirmation = "password123"
  dev.role = User::EMPLOYEE
  dev.is_active = true
  dev.is_published = true
  dev.approval_path_id = approval_path.id
  dev.weekend_id = weekend.id
  dev.holiday_scheme_id = holiday_scheme.id
  dev.personal_email = "dev1@personal.com"
  dev.mobile_number = "0181000001"
  dev.joining_date = Date.today
  dev.registration_status = User::REGISTRATION_STATUS[:registered]
  dev.employee_id = dev_employee_id
  dev.ttf_id = ttf_user.id
end

dev_user.ttf_id = ttf_user.id
dev_user.save!

puts "Developer #{dev_user.name} has TTF ID: #{dev_user.ttf_id}"
