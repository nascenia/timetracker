ActiveAdmin.register Attendance do

   permit_params :user_id, :checkin_date, :in, :out, :total_hours, :is_first_entry

   index do
     selectable_column
     id_column
     column 'User' do |obj|
       obj.user.name if obj.user.present?
     end
     column :checkin_date
     column :in do |obj|
       Time.at(obj.in_time).utc.strftime("%I:%M%p") if obj.in_time.present?
     end
     column :out do |obj|
       Time.at(obj.out_time).utc.strftime("%I:%M%p") if obj.out_time.present?
     end
     column :total_hours

     actions
   end
end
