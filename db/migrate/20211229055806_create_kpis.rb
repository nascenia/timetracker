class CreateKpis < ActiveRecord::Migration
  def change
    create_table :kpis do |t|
      t.references  :user, index: true
      t.string      :title, null: false
      t.text        :description
      t.integer     :score
      t.date        :start_date
      t.date        :end_date
      t.integer     :status

      t.timestamps
    end
  end
end
