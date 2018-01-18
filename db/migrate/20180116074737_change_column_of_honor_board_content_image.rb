class ChangeColumnOfHonorBoardContentImage < ActiveRecord::Migration
  def change
    remove_column :honor_board_contents, :image_url
    add_column :honor_board_contents, :image, :longblob
  end
end
