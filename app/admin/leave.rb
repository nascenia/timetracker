ActiveAdmin.register Leave do
  permit_params :user_id, :reason, :leave_type, :pending_at, :status, :start_date, :end_date, :half_day

  index do
    selectable_column
    id_column
    column 'User' do |obj|
      obj.user.name if obj.user.present?
    end
    column :leave_type do |obj|
      if obj.leave_type == Leave::CASUAL
        'Casual'
      elsif obj.leave_type == Leave::UNANNOUNCED
        'Unannounced'
      else
        'Medical'
      end
    end
    column :reason do |body|
      truncate(body.reason, omision: '...', length: 15)
    end
    column :start_date do |obj|
      obj.start_date.strftime("%d-%m-%Y") if obj.start_date.present?
    end
    column :end_date do |obj|
      obj.end_date.strftime("%d-%m-%Y") if obj.end_date.present?
    end
    column :half_day
    column :pending_at
    column :status do |obj|
      if obj.status == Leave::ACCEPTED
        'Approved'
      elsif obj.status == Leave::REJECTED
        'Rejected'
      else
        'Pending'
      end
    end

    actions
  end

  form do |f|
    f.inputs "User Details" do
      f.input :user_id
      f.input :reason
      f.input :start_date
      f.input :end_date
      f.input :half_day
      f.input :leave_type, as: :select, collection: Leave::LEAVE_TYPES
      f.input :pending_at
      f.input :status, as: :select, collection: Leave::LEAVE_STATUSES
    end
    f.actions
  end
end
