class AddColumnTeamToDesignations < ActiveRecord::Migration[7.0]
  def change
    add_column :designations, :team, :string, after: :id
  end
end
