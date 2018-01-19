class HonorBoardContentsController < ApplicationController
before_action :set_side_menu

  layout 'time_tracker'


  def index
  @honor_board_contents = HonorBoardContent.all
  end

  def show
    @honor_board_content = HonorBoardContent.find(params[:id])
  end
  def new
    redirect_to honor_board_category_path
  end
  def update
   redirect_to
  end

  def method_404
    render :layout => false
  end

  def destroy
    @honor_board_content = HonorBoardContent.find(params[:id])

    if @honor_board_content.thumbnail.destroy && @honor_board_content.destroy
      redirect_to honor_board_contents_path
    end

  end

  private
  def set_side_menu
    @honor_board_categories = HonorBoardCategory.all
  end


end
