every :weekday, :at => '6:00 pm' do
  runner "User.create_unannounced_leave"
end
