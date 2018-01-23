class ChanheCatagoryColumnTitleToCatagory < ActiveRecord::Migration
  def change
    rename_column :honor_board_categories, :title, :category
  end
end
