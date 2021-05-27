class RemoveRedirectionFlagFromPreRegistrations < ActiveRecord::Migration
  def change
    remove_column :pre_registrations, :redirection_flag, :boolean
  end
end
