ActiveAdmin.register Project do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
permit_params :project_name, :description, :is_active

form do |f|
  f.inputs 'Project Details' do
    f.input :project_name
    f.input :description
    f.input :is_active
  end
  f.actions
end

end
