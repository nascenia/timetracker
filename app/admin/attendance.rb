ActiveAdmin.register Attendance do


  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
   permit_params :user_id, :datetoday, :in_time, :out_time, :total_hours, :first_entry

   index do
     selectable_column
     id_column
     column 'User' do |obj|
       obj.user.name if obj.user.present?
     end
     column :datetoday
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
