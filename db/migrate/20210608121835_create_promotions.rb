class CreatePromotions < ActiveRecord::Migration[7.0]
  def change
    create_table :promotions do |t|
      t.references  :user, index: true
      t.string      :designation
      t.string      :start_date
      t.string      :end_date

      t.timestamps
    end
  end
end
