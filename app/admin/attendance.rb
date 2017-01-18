ActiveAdmin.register Attendance do

   permit_params :user_id, :checkin_date, :in_time, :out_time, :total_hours, :parent_id

   index do
     selectable_column
     id_column
     column 'User' do |obj|
       obj.user.name if obj.user.present?
     end
     column :checkin_date
     column :in_time do |obj|
       Time.at(obj.in_time).utc.strftime('%I:%M%p') if obj.in_time.present?
     end
     column :out_time do |obj|
       Time.at(obj.out_time).utc.strftime('%I:%M%p') if obj.out_time.present?
     end
     column :total_hours

     actions
   end
end
