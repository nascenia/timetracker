ActiveAdmin.register HonorBoardContent do
  actions :all, except: [:destroy]
  permit_params :id, :name, :reason, :photo, :honor_board_category_id, :created_at, :updated_at

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
      f.input :photo
      f.input :honor_board_category_id, as: :select , :collection => HonorBoardCategory.all.map{|c| [ c.category, c.id ]}, :prompt => "select category"

    end
    f.actions
  end

  controller do
    def destroy # => Because of this the 'Delete' button was still there

      @honor_board_content = HonorBoardContent.find_by_id(params[:id])
      @honor_board_content.destroy
      redirect_to :back
    end
  end

end
