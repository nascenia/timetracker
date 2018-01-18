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
  @honor_board_content = HonorBoardContent.new
    @honor_board_categories = HonorBoardCategory.all
  end

  def create
    @honor_board_content = HonorBoardContent.new(content_params(params))
    if @honor_board_content.save
      notice = "Story added successfully"
      redirect_to honor_board_contents_path, notice: notice
    else
      render 'new'
    end
  end

  def update

  end

  private
  def set_side_menu
    @honor_board_categories = HonorBoardCategory.all
  end
  def content_params(params)
    params.require(:honor_board_content).permit(:name, :reason, :thumbnail, :category_id)
  end


end
