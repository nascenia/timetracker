ActiveAdmin.register GoalCategory do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params [:title, :description, :published], :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #   permitted = [:title, :description, :published]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
