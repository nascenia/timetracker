ActiveAdmin.register Timesheet do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

  index do
    column :id
    column :task
    column :description
    column :date
    column :hours
    column :minutes
    column  'Project' do |timesheet|
      timesheet.project.present? ? timesheet.project.project_name : 'n/a'
    end
    column  'User' do |timesheet|
      timesheet.user.present? ? timesheet.user.name : 'n/a'
    end
    column :created_at
    column :updated_at
    actions
  end
end
