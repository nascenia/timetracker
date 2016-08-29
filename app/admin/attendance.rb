ActiveAdmin.register Attendance do


  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
   permit_params :user_id, :datetoday, :in, :out, :total_hours, :first_entry

   index do
     selectable_column
     id_column
     column 'User' do |obj|
       obj.user.name if obj.user.present?
     end
     column :datetoday
     column :in do |obj|
       Time.at(obj.in).utc.strftime("%I:%M%p") if obj.in.present?
     end
     column :out do |obj|
       Time.at(obj.out).utc.strftime("%I:%M%p") if obj.out.present?
     end
     column :total_hours

     actions
   end
end
