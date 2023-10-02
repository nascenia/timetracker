class AddFavIconToSettings < ActiveRecord::Migration[7.0]
  def change
    add_column :settings, :fav_icon, :string
  end
end
