class PromotionsController < ApplicationController
  before_action :authenticate_user!

  def new
    unless current_user.has_admin_privilege?
      flash[:notice]  = 'Sorry, You have no permission.'

      redirect_to :back
    end

    @promotion = Promotion.new(user_id: params[:employee_id])
  end

  def create
    unless current_user.has_admin_privilege?
      flash[:notice]  = 'Sorry, You have no permission.'

      redirect_to :back
    end

    @promotion = Promotion.new(promotion_params)
    
    if @promotion.save
      flash[:notice]  = 'Promotion added successfully.'
      redirect_to employee_path(promotion_params[:user_id])
    else
      flash[:notice]  = 'Sorry unable to create promotion.'
      redirect_to employee_path(promotion_params[:user_id])
    end
  end

  private

  def promotion_params
    params.require(:promotion).permit(:user_id, :designation, :start_date, :end_date)
  end
end
