ActiveAdmin.register Promotion do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params [:user_id, :designation, :start_date, :end_date], :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

  index do
    column  :id
    column  'Name' do |promotion|
      "#{promotion.user.name}"
    end
    column  'Email' do |promotion|
      "#{promotion.user.email}"
    end
    column  :designation
    column  :created_at
    column  :updated_at
    actions
  end

end
