class CreateGoalCategories < ActiveRecord::Migration
  def change
    create_table :goal_categories do |t|
      t.string    :title
      t.text      :description
      t.boolean   :published

      t.timestamps
    end
  end
end
