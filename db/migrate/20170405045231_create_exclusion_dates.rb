class CreateExclusionDates < ActiveRecord::Migration
  def change
    create_table :exclusion_dates do |t|
      t.date :date, null: false
      t.references :excluded, polymorphic: true, index: true

      t.timestamps
    end
  end
end
