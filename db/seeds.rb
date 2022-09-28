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

unless User.exists?(email: 'masud@nascenia.com')
  User.create(name: 'Masud', email: "masud@nascenia.com", password: 'Admin@123', password_confirmation: 'Admin@123')
end

if HolidayScheme.count.zero?
  HolidayScheme.create([
    { name: 'Nascenia General', active: true, leave_year_id: 1 },
    { name: 'GJ and Biyeta', active: true, leave_year_id: 1 },
  ])
end 

if Weekend.count.zero?
  Weekend.create([
    { name: 'Nascenia Core: Sat & Sun', off_days: nil },
    { name: 'Admin: Sat', off_days: nil },
    { name: 'Biyeta: Thu & Fri', off_days: nil }
  ])
end

#Create present year and mark it as present
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
