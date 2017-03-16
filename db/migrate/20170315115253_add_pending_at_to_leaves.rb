class AddPendingAtToLeaves < ActiveRecord::Migration
  def change
    add_column :leaves, :pending_at, :integer, null: false
  end
end
