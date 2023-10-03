# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if HolidayScheme.count.zero?
  p 'Creating holiday scheme ...'
  HolidayScheme.create([
    { name: 'Nascenia General', active: true, leave_year_id: 1 },
    { name: 'GJ and Biyeta', active: true, leave_year_id: 1 },
  ])
  p 'Done'
end 

if Weekend.count.zero?
  p 'Creating weekend...'
  Weekend.create([
    { name: 'Nascenia Core: Sat & Sun', off_days: nil },
    { name: 'Admin: Sat', off_days: nil },
    { name: 'Biyeta: Thu & Fri', off_days: nil }
  ])
  p 'Done'
end

#Create present year and mark it as present
if LeaveYear.count.zero?
  p 'Creating leave year...'
  LeaveYear.find_or_create_by(year: Date.today.year.to_s, present: true)
  p 'Done'
end

if Designation.count.zero?
  p 'Creating employee designations...'
  Designation.create([
    { team: 'Developer', title: 'Intern', description: 'Internship', published: true },
    { team: 'Developer', title: 'Junior Software Engineer', description: 'Junior software engineer', published: true },
    { team: 'Developer', title: 'Software Engineer', description: 'Software engineer', published: true },
    { team: 'Developer', title: 'Senior Software Engineer', description: 'Senior software engineer', published: true }
  ])
  p 'Done'
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

if KpiTemplate.count.zero?
  p 'Creating KPI template...'
  KpiTemplate.create([
    { title: 'Junior software engineer', description: 'for junior software engineers', published: true },
    { title: 'Accounts and finance', description: 'For accounts and finance department', published: true },
    { title: 'Human resource', description: 'For human resource team', published: true }
  ])
  p 'Done'
end

if ApprovalPath.count.zero?
  p 'Creating approval path...'
  ApprovalPath.create([
    { name: 'CEO'},
    { name: 'Business Development' },
    { name: 'Human resource' }
  ])
  p 'Done'
end

if Setting.count.zero?
  p 'Creating setting...'
  Setting.create([
    app_name: 'timetracker',
    organization_name: 'Nascenia',
    organization_summary: 'Software development company'
  ])
  p 'Done'
end

unless User.exists?(email: 'masud@nascenia.com')
  p 'Creating user...'
  user = User.new(
    name: 'Masud', 
    email: "masud@nascenia.com", 
    password: 'Admin@123', 
    password_confirmation: 'Admin@123', 
    employee_id: 'A0001')
  user.holiday_scheme = HolidayScheme.first
  user.approval_path = ApprovalPath.first
  user.kpi_template = KpiTemplate.first
  user.save!
  p 'Done'
end