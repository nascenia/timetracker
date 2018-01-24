class AddPhotoFieldToHonorBoardContents < ActiveRecord::Migration
  def change
    add_column :honor_board_contents, :photo, :string
  end
end
