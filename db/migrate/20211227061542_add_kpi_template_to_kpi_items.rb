class AddKpiTemplateToKpiItems < ActiveRecord::Migration[7.0]
  def change
    add_reference :kpi_items, :kpi_template, index: true
  end
end
