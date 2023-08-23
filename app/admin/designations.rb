ActiveAdmin.register Designation do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params [:team, :title, :description, :published], :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #   permitted = [:team, :title, :description, :published]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  form do |f|
    f.inputs do
      f.input :team, :label => 'Team', :as => :select, :collection => [['Developer', 'Developer'], ['SQA', 'SQA'], ['Business', 'Business']]
      f.input :title
      f.input :description
      f.input :published
    end
    f.actions
  end
end
