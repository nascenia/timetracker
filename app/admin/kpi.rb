ActiveAdmin.register Kpi do

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
    selectable_column
    id_column
    column :start_date
    column :end_date
    column :ttf_comment
    column :team_member_comment
    column :score
    column :status do |kpi|
      kpi.status == 0 ? 'In-Review' : 'Approved'
    end
    actions
  end

  show do
    attributes_table do
      row   :id
      row   :user
      row   :start_date
      row   :end_date
      row   :ttf_comment
      row   :team_member_comment
      row   :status do |kpi|
        kpi.status == 0 ? 'In-Review' : 'Approved'
      end
    end

    kpi_items = kpi.user.kpi_template.kpi_items

    panel "KPI Items" do
      table_for kpi_items do
        column :title
        column  :score do
          '0.0'
        end
      end
    end
    
  end
end
