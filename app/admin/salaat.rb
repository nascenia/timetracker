ActiveAdmin.register Salaat do

  permit_params :waqt, :time

  index do
    selectable_column
    id_column

    column :waqt
    column :time do |salaat|
      salaat.time.utc.strftime('%I:%M')
    end
    actions
  end

  form do |f|
    f.inputs 'Salaat Details' do
      f.input :waqt
      f.input :time
    end
    f.actions
  end
end
