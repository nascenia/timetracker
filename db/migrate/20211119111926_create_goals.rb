class CreateGoals < ActiveRecord::Migration
  def change
    create_table :goals do |t|
      t.integer     :user_id
      t.integer     :goal_category_id
      t.integer     :reviewer_id
      t.string      :title
      t.text        :description
      t.decimal     :point, precision: 5, scale: 2
      t.decimal     :percent_completed, precision: 5, scale: 2
      t.decimal     :achived_point, precision: 5, scale: 2
      t.text        :deliverable_link
      t.text        :comments
      t.date        :start_date
      t.date        :end_date
      t.integer     :status

      t.timestamps
    end
  end
end
