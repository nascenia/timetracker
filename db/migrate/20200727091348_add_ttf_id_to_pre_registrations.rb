class AddTtfIdToPreRegistrations < ActiveRecord::Migration[7.0]
  def change
    add_column :pre_registrations, :ttf_id, :integer
  end
end
