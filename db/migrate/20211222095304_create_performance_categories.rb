class CreatePerformanceCategories < ActiveRecord::Migration
  def change
    create_table :performance_categories do |t|
      t.string :title
      t.text :description
      t.boolean :published

      t.timestamps
    end
  end
end
