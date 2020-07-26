class RemoveRedirectFlagFromPreRegistrations < ActiveRecord::Migration
  def change
    remove_column :pre_registrations, :redirect_flag, :boolean
  end
end
