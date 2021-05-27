class AddRedirectionFlagToPreRegistrations < ActiveRecord::Migration
  def change
    add_column :pre_registrations, :redirection_flag, :boolean
  end
end
