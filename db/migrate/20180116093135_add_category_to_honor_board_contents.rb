class AddCategoryToHonorBoardContents < ActiveRecord::Migration
  def change
    add_reference :honor_board_contents, :category, index: true
  end
end
