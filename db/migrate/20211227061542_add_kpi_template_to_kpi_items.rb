class AddKpiTemplateToKpiItems < ActiveRecord::Migration
  def change
    add_reference :kpi_items, :kpi_template, index: true
  end
end
