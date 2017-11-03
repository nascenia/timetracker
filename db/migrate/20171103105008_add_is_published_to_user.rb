class AddIsPublishedToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_published, :boolean, default: false
  end
end
