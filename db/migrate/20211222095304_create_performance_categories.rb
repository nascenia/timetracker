class CreatePerformanceCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :performance_categories do |t|
      t.string :title
      t.text :description
      t.boolean :published

      t.timestamps
    end
  end
end
