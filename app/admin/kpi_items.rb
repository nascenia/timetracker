ActiveAdmin.register KpiItem do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :title, :description, :kpi_template_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:title, :description, :kpi_template_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
  form do |f|
    f.inputs "KPI items" do
      f.input :kpi_template
      f.input :title
      f.input :description
    end
    f.actions
  end

  index do
    column  :id
    column  'KPI Template' do |kpi_item|
      "#{kpi_item.kpi_template.title}"
    end
    column  :title
    column  :description
    
    column  :created_at
    column  :updated_at
    actions
  end
end
