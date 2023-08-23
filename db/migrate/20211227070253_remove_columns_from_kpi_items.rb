class RemoveColumnsFromKpiItems < ActiveRecord::Migration[7.0]
  def change
    remove_column :kpi_items,   :score
    remove_column :kpi_items,   :start_date  
    remove_column :kpi_items,   :end_date    
    remove_column :kpi_items,   :status     
  end
end
