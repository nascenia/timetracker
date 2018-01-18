class DeleteImageFieldHonorBoardContent < ActiveRecord::Migration
  def change
    remove_column :honor_board_contents, :image
  end
end
