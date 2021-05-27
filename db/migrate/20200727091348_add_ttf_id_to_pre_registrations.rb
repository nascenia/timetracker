class AddTtfIdToPreRegistrations < ActiveRecord::Migration
  def change
    add_column :pre_registrations, :ttf_id, :integer
  end
end
