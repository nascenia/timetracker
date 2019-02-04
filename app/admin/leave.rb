ActiveAdmin.register Leave do
  permit_params :user_id, :reason, :leave_type, :pending_at, :status, :start_date, :end_date, :half_day

  controller do
    def update
      p params
      if current_user.has_edit_permission_for?(User.find(id=params[:leave][:user_id]))
        update!
      else
        flash[:error] = "You don't have permission to edit. Contact the Super Admin."
        redirect_to :edit_admin_leave and return
      end
    end

    def create
      if current_user.has_edit_permission_for?(User.find(id=params[:leave][:user_id]))
        create!
      else
        flash[:error] = "You don't have permission to create. Contact the Super Admin."
        redirect_to :new_admin_leave and return
      end
    end
  end

  index do
    selectable_column
    id_column
    column 'User' do |obj|
      obj.user.name if obj.user.present?
    end
    column :leave_type do |obj|
      if obj.leave_type == Leave::CASUAL
        'Casual'
      elsif obj.leave_type == Leave::MEDICAL
        'Medical'
      elsif obj.leave_type == Leave::UNANNOUNCED
        'Unannounced'
      elsif obj.leave_type == Leave::AWARDED
        'Awarded'
      elsif obj.leave_type == Leave::PATERNITY
        'Paternity'
      elsif obj.leave_type == Leave::MATERNITY
        'Maternity'
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
    column :half_day do |obj|
      if obj.half_day == Leave::FIRST_HALF
        'First Half'
      elsif obj.half_day == Leave::SECOND_HALF
        'Second Half'
      elsif obj.half_day == Leave::FIRST_QUARTER
        'Late'
      elsif obj.half_day == Leave::FULL_DAY
        'Full Day'
      end

    end
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
