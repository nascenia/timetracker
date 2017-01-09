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

  # leaves controller resources generates wrong typo in url helper
  get '/leaves', to: 'leaves#index', as: 'leaves'
  get '/leaves/new', to: 'leaves#new', as: 'new_leave'
  post '/leaves', to: 'leaves#create'
  get '/leaves/:id', to: 'leaves#show', as: 'leave'
  get '/leaves/:id/edit', to: 'leaves#edit', as: 'edit_leave'
  put '/leaves/:id', to: 'leaves#update'
  delete '/leaves/:id', to: 'leaves#destroy'
  get 'leaves/:id/approve', to: 'leaves#approve', as: 'approve_leave'

  resources :attendances do
    collection do
      get :update_salaat_time
      get :six_months_data
      get :monthly_report
      get :raw_attendance_data
      get :monthly_summary
    end
  end

  root :to => 'dashboard#index'
end
