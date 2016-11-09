Internal::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  resources :users do
    member do
      get :leave
      get :team
    end
  end

  resources :leaves do
    member do
      get :approve_or_reject_leave
      get :approve
      get :reject
    end

    collection do
      get :employee_list
      get :pending_for_approval
    end
  end

  resources :attendances do
    member do
      get :hide_name
      get :show_name
      get :multi_entry_list
    end

    collection do
      get :search_daily_attendance
      get :update_salaat_time
      get :six_months_data
      get :monthly_report
      get :raw_attendance_data
      get :show_hidden_names
    end
  end

  root :to => 'attendances#index'
end
