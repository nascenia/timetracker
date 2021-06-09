class AddColumnTeamToDesignations < ActiveRecord::Migration
  def change
    add_column :designations, :team, :string, after: :id
  end
end
