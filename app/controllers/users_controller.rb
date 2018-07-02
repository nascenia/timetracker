class UsersController < ApplicationController
  before_action :authenticate_admin_user!, only: [:edit_review_registration, :review_registration]
  layout 'leave'

  before_action :authenticate_user!

  def index
    @super_ttf = User.super_ttf

    respond_to do |format|
      format.html
    end
  end

  def team
    user = User.find params[:id]

    if user.is_admin?
      @team = User.active.order(name: :asc)
    elsif user.role == User::SUPER_TTF || user.role == User::TTF || user.owned_paths.length > 0
      @team = user.get_co_workers
    else
      flash[:notice] = 'Sorry! This page is only for TTF / Super TTF!'
      redirect_to leave_tracker_path(current_user) and return
    end

    respond_to do |format|
      format.html
    end
  end

  def download
    @users = User.all.order(:email)

    respond_to do |format|
      format.xls {send_data @users.to_csv(col_sep: "\t")}
    end
  end

  def review_registration
    @user = User.find(params[:id])
    if params[:status] == "Accept"
      @user.update_attribute(:registration_status, User::REGISTRATION_STATUS[:registered])
      flash[:warning] = "User registration Accepted"
      redirect_to employee_path(@user)
      return
    else
      @user.update_attribute(:registration_status, User::REGISTRATION_STATUS[:not_registered])
      flash[:warning] = "User registration has been Rejected."
      redirect_to new_review_registration_comment_user_path(@user), turbolinks: false
    end

  end
  def new_review_registration_comment
      @user = User.find(params[:id])
  end
  def send_review_registration_comment
    @user = User.find(params[:id])
    UserMailer.send_rejection_notification_of_employee_registration_to_user(@user,params[:body]).deliver
    redirect_to employee_path(@user)
  end


  def edit_review_registration
    @user = User.find(params[:id])
  end

  private

    def user_params
      params.require(:user).permit(:email, :name, :is_active, :personal_email, :present_address, :mobile_number, :alternate_contact,
                                   :permanent_address, :date_of_birth, :last_degree, :last_university, :passing_year,
                                   :emergency_contact_person_name, :emergency_contact_person_relation,
                                   :emergency_contact_person_number, :blood_group, :joining_date,:name,:avatar)
    end
end
