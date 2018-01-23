class CreateHonorBoardCategories < ActiveRecord::Migration
  def change
    create_table :honor_board_categories do |t|
      t.string :title,    null: false, default: ""

      t.timestamps
    end
  end
end
