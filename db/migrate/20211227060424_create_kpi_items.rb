class CreateKpiItems < ActiveRecord::Migration
  def change
    create_table :kpi_items do |t|
      t.string :title
      t.text :description
      t.integer :score
      t.date :start_date
      t.date :end_date
      t.integer :status

      t.timestamps
    end
  end
end
