class AddAttachmentThumbnailToHonorBoardContents < ActiveRecord::Migration
  def self.up
    change_table :honor_board_contents do |t|
      t.attachment :thumbnail
    end
  end

  def self.down
    remove_attachment :honor_board_contents, :thumbnail
  end
end
