class AddRedirectionFlagToPreRegistrations < ActiveRecord::Migration[7.0]
  def change
    add_column :pre_registrations, :redirection_flag, :boolean
  end
end
