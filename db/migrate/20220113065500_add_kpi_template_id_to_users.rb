class AddKpiTemplateIdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column  :users, :kpi_template_id, :integer
  end
end
