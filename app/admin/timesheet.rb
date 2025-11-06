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

  csv do
    column :id
    column :date
    column :task
    column :description
    column :hours
    column :minutes
    column('Project') { |timesheet| timesheet.project.present? ? timesheet.project.project_name : 'n/a' }
    column('User') { |timesheet| timesheet.user.present? ? timesheet.user.name : 'n/a' }
    column :created_at
    column :updated_at
  end

#
#   ActiveAdmin’s filter DSL builds form fields in the sidebar and then hands the submitted values to Ransack, 
#   which translates them into ActiveRecord queries. The as: and the particular filter name control:
#   what input widget you see (select / text / date range / numeric),
#   which Ransack predicate is used (e.g. _cont, _eq, _gteq),
#   what gets sent in the request parameters (under q[...]),
#   and therefore what SQL is generated.
#

  filter :user, as: :select, collection: -> { User.all.pluck(:name, :id) }
  filter :project, as: :select, collection: -> { Project.all.pluck(:project_name, :id) }
  filter :date
  filter :description, as: :string
  filter :created_at
  filter :updated_at
  filter :task,        as: :string
  filter :ticket_number, as: :string
  filter :ticket_link,   as: :string
  filter :hours, as: :numeric, label: 'Hours'
  filter :minutes, as: :numeric, label: 'Minutes'

  form do |f|
    f.inputs 'Timesheet Details' do
      f.input :user, as: :select, collection: User.all.pluck(:name, :id)
      f.input :project, as: :select, collection: Project.all.pluck(:project_name, :id)
      f.input :date, as: :date_select, start_year: 2020, end_year: 2030
      f.input :description
      f.input :task
      f.input :ticket_number
      f.input :ticket_link
      f.input :hours
      f.input :minutes
    end
    f.actions
  end

end
