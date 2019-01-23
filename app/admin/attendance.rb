ActiveAdmin.register Attendance do

   permit_params :user_id, :checkin_date, :in_time, :out_time, :total_hours, :parent_id

   after_create do |attendance|
     attendance.out_time=nil
     attendance.save
   end
   controller do
     def update
       if current_user.has_edit_permission_for?(User.find(id=params[:attendance][:user_id]))
         update!
       else
         flash[:error] = "You don't have permission to edit. Contact the Super Admin."
         redirect_to :edit_admin_attendance and return
       end
     end

     def create
       if current_user.has_edit_permission_for?(User.find(id=params[:attendance][:user_id]))
         create!
       else
         flash[:error] = "You don't have permission to create. Contact the Super Admin."
         redirect_to :new_admin_attendance and return
       end
     end
   end



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
