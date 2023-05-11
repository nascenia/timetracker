ActiveAdmin.register Goal do

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
    column :title
    column :description
    column :point
    column :percent_completed
    column :achived_point
    column :start_date
    column :end_date
    column 'Category' do |goal|
      goal.goal_category.present? ? goal.goal_category.title : 'n/a'
    end
    column 'User' do |goal|
      goal.user.present? ? goal.user.name : 'n/a'
    end
    column :status do |goal|
      Goal::STATUSES[goal.status]
    end
    actions
  end
end
