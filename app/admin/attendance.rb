ActiveAdmin.register Attendance do
   preserve_default_filters!
   remove_filter :children
   filter :user, label: 'User', collection: proc { User.order(:name)}
   permit_params :user_id, :checkin_date, :in_time, :out_time, :total_hours, :parent_id

   csv do
     column :id
     column (:name) { |a| a.user.name}
     column :checkin_date
     column :in_time
     column :out_time
     column :created_at
     column :updated_at
     column :total_hours
   end

   after_create do |attendance|

     if params[:attendance]['out_time(4i)'].present? && params[:attendance]['out_time(5i)'].present?
       attendance= Attendance.find(attendance.id)
       attendance.total_hours = ((attendance.out_time.to_time - attendance.in_time.to_time) / 1.hour).round(2)
     else
       attendance.out_time = nil
     end
     attendance.save

   end
   after_update do |attendance|
     if attendance.in_time.present? && attendance.out_time.present?
       attendance= Attendance.find(attendance.id)
       attendance.total_hours = ((attendance.out_time.to_time - attendance.in_time.to_time) / 1.hour).round(2)
       attendance.save
     end
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
