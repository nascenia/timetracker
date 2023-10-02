ActiveAdmin.register Setting do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :app_name, :organization_name, :organization_summary, :organization_logo, :organization_web_url, :copyright, :meta_author, :meta_title, :meta_description, :meta_keywords, :meta_viewport
  #
  # or
  #
  # permit_params do
  #   permitted = [:app_name, :organization_name, :organization_summary, :organization_logo, :organization_web_url, :copyright, :meta_author, :meta_title, :meta_description, :meta_keywords, :meta_viewport]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
