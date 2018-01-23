class HonorBoardCategoriesController < ApplicationController
  before_action :set_side_menu

  layout 'time_tracker'


  def index
   @honor_board_categories = HonorBoardCategory.all
  end

  def show
    @contents = HonorBoardContent.where ("honor_board_category_id = #{params[:id]}")
  end

  private
  def set_side_menu
    @honor_board_categories = HonorBoardCategory.all
  end
end
