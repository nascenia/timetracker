class RenameCategoryIdFieldToCategory < ActiveRecord::Migration
  def change
    rename_column :honor_board_contents, :category_id, :honor_board_category_id
  end
end
