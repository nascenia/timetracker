class CreateSalaats < ActiveRecord::Migration
  def change
    create_table :salaats do |t|
      t.string :waqt
      t.time :time

      t.timestamps
    end
  end
end
