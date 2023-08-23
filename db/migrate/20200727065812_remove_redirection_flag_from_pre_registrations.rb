class RemoveRedirectionFlagFromPreRegistrations < ActiveRecord::Migration[7.0]
  def change
    remove_column :pre_registrations, :redirection_flag, :boolean
  end
end
