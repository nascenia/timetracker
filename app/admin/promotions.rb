ActiveAdmin.register Promotion do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params [:user_id, :designation, :start_date, :end_date], :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #   permitted = [:designation, :start_date, :end_date, :user_id]
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
    column  :start_date do |promotion|
      promotion.start_date.split('T').first
    end
    column  :created_at
    column  :updated_at
    actions
  end

  form do |f|
    f.inputs do
      f.input :user_id, :as => :select, :collection => User.active.map{ |u| [u.name, u.id] }
      f.input :designation, :as => :select, :collection => Designation.published.map{ |d| [d.title, d.title] }
      f.input :start_date, as: :date_picker
      f.input :end_date, as: :date_picker
    end
    f.actions
  end
end
