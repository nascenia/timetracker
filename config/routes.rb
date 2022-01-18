Internal::Application.routes.draw do
  get "promotions/new"
  get "projects/index"
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks", :registrations => 'users/registrations' }

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  resources :approval_chains do
    member do
      get   :remove
      post  :assign
    end
    collection do 
      get   :ttf_own
      post  :create_chain
    end
  end

  resources :leave_tracker

  resources :users do
    member do
      get :leave
      get :team
      post :review_registration
      get  :new_review_registration_comment
      post :send_review_registration_comment
      get :edit_review_registration
    end

    collection do
      get :download
    end
  end

  # leaves_controller projects generate paths with 'leafe' as singular for 'leaves'
  # That is why we defined plural and singular for leave in config/initializers/inflections.rb
  resources :leaves do
    member { post :approve, :reject, :award, :special_award}
    resources :comments, only: [:new, :create]
  end

  resources :comments, only: [:edit, :update, :destroy]

  resources :attendances do
    collection do
      get :monthly_summary
      get :download
    end
  end
  resources :timesheets do
    # collection do
    #   get :index
    # end
  end
  resources :projects do
    collection do
      get :show_all
      get :weekly_report
      get :download_projects
      get :monthly_report
    end
  end


  resources :salaats
  resources :pre_registrations do
    collection do
      get :remove
    end
  end

  resources :weekends do
    member do
      post :assign
      get :remove
      get :detail
    end

    resources :exclusion_dates, except: :index
  end

  resources :holiday_schemes do
    member do
      get :assign_form
      get :remove
      post :assign
    end

    resources :exclusion_dates, except: :index
  end

  resources :holidays

  resources :super_admin_leaves, only: :index do
    member { patch :change_type }
  end

  get 'salaat_times', to: 'salaat_times#index'
  resources :employees do
    resources :promotions, only: [:new, :create]
  end

  resources :goals do
    collection do
      get :review
    end
  end

  resources :kpis do
    collection do
      get   :review
    end
  end
  resources :kpi_items
  
  root :to => 'dashboard#index'
end
