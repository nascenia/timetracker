class CreateKpiTemplates < ActiveRecord::Migration
  def change
    create_table :kpi_templates do |t|
      t.string :title
      t.text :description
      t.boolean :published

      t.timestamps
    end
  end
end
