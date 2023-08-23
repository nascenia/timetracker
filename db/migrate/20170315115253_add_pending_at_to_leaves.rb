class AddPendingAtToLeaves < ActiveRecord::Migration[7.0]
  def change
    add_column :leaves, :pending_at, :integer, null: false
  end
end
