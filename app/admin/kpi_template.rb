ActiveAdmin.register KpiTemplate do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params [:title, :description, :published], :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

  action_item :kpi_item, only: :show do
    link_to 'New KPI Item', new_admin_kpi_item_path
  end

  show do
    default_main_content

    div do
      render 'kpi_item', { kpi: kpi_template }
    end
  end

end
