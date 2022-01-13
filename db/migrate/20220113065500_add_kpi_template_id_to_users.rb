class AddKpiTemplateIdToUsers < ActiveRecord::Migration
  def change
    add_column  :users, :kpi_template_id, :integer
  end
end
