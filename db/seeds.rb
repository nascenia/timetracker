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

#Create present year and mark it as present
if LeaveYear.count.zero?
  p 'Creating LeaveYear...'
  LeaveYear.find_or_create_by(year: Date.today.year.to_s, present: true)
end

if Designation.count.zero?
  p 'Creating employee designations...'
  Designation.create([
    { title: 'Intern', description: 'Internship', published: true },
    { title: 'Junior Software Engineer', description: 'Junior software engineer', published: true },
    { title: 'Software Engineer', description: 'Software engineer', published: true },
    { title: 'Senior Software Engineer', description: 'Senior software engineer', published: true }
  ])
end
