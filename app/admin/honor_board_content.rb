ActiveAdmin.register HonorBoardContent do
  permit_params :name, :reason, :thumbnail, :category_id

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

  form do |f|
    f.inputs "Honor Board Content Details" do
      f.input :name
      f.input :reason
      f.input :thumbnail
      f.input :category_id, as: :select , :collection => HonorBoardCategory.ids

    end
    f.actions
  end


end
