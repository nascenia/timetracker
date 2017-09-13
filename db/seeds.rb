# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Salaat.create(waqt: 'Zohr', time: '1:30')
Salaat.create(waqt: 'Asor', time: '4:15')
Salaat.create(waqt: 'Magrib', time: '5:30')

#Create present year and mark it as present
LeaveYear.find_or_create_by(year: Date.today.year.to_s, present: true)
