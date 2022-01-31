ActiveAdmin.register Kpi do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
  permit_params [:user_id, :start_date, :end_date, :ttf_comment, :team_member_comment, :data, :status], :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

  actions :all, except: [:new]

  filter  :user, as: :select, collection: proc { User.active }
  filter  :start_date
  filter  :end_date
  filter  :status, as: :select, collection: Kpi::STATUSES.to_a

  index download_links: [:csv] do
    selectable_column
    id_column
    column :user
    column :start_date do |kpi|
      kpi.start_date.strftime('%Y-%m-%d')
    end
    column :end_date do |kpi|
      kpi.end_date.strftime('%Y-%m-%d')
    end
    column :ttf_comment
    column :team_member_comment
    column :score
    column :status do |kpi|
        kpi_status_str(kpi.status)
    end
    actions
  end

  show do
    attributes_table do
      row   :id
      row   :user
      row   :start_date do |kpi|
        kpi.start_date.strftime('%Y-%m-%d')
      end
      row   :end_date do |kpi|
        kpi.end_date.strftime('%Y-%m-%d')
      end
      row   :ttf_comment
      row   :team_member_comment
      row   :score
      row   :status do |kpi|
        kpi_status_str(kpi.status)
      end
    end

    kpi_items = kpi.user.kpi_template.kpi_items
    data = JSON.parse(kpi.data)

    panel "KPI Items" do
      table_for kpi_items do
        column :title
        column  :score do |kpi_item|
          item = data.find{ |item| item['item_id'] == kpi_item.id }
          score = item.blank? ? '' : item['score']
          score
        end
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :user, as: :select, collection: User.active
      f.input :status,  as: :select, collection: Kpi::STATUSES
      f.input :ttf_comment
      f.input :team_member_comment
      f.input :start_date
      f.input :end_date
    end
    render partial: 'kpi_items', locals: { kpi: kpi, kpi_items: KpiItem.where(id: JSON.parse(kpi.data).map{|d| d['item_id']}) }
    f.actions
  end

  controller do
    def update
      data      = []
      item_ids  = params[:kpi_item_ids].map{|id| id.to_i}
      item_ids.each_with_index do |item_id, i|
        data << { item_id: item_id, score: params[:kpi_item_score][i].to_f }
      end

      kpi                     = Kpi.find(params[:id])
      kpi.status              = params[:kpi][:status]
      kpi.user_id             = params[:kpi][:user_id]
      kpi.ttf_comment         = params[:kpi][:ttf_comment]
      kpi.team_member_comment = params[:kpi][:team_member_comment]
      kpi.start_date          = Date.strptime("#{params[:kpi]['start_date(1i)']}-#{params[:kpi]['start_date(2i)']}-#{params[:kpi]['start_date(3i)']}")
      kpi.end_date            = Date.strptime("#{params[:kpi]['end_date(1i)']}-#{params[:kpi]['end_date(2i)']}-#{params[:kpi]['end_date(3i)']}")
      kpi.data                = data.to_json

      if kpi.save
        redirect_to :admin_kpis, notice: 'KPI updated successfully.'
      else
        redirect_to :admin_kpis, notice: 'Sorry, Unable to updatee KPI'
      end
    end
  end

  csv do
    column   :id
    column   :user do |kpi|
      kpi.user.name
    end
    column   :start_date do |kpi|
      kpi.start_date.strftime('%Y-%m-%d')
    end
    column   :end_date do |kpi|
      kpi.end_date.strftime('%Y-%m-%d')
    end
    column   :ttf_comment
    column   :team_member_comment
    column   :score
    column   :status do |kpi|
      kpi_status_str(kpi.status)
    end
  end
end
