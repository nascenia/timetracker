class CreateHonorBoardContents < ActiveRecord::Migration
  def change
    create_table :honor_board_contents do |t|
      t.string :name
      t.text :reason
      t.string :image_url

      t.timestamps
    end
  end
end
