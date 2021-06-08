class CreateDesignations < ActiveRecord::Migration
  def change
    create_table :designations do |t|
      t.string  :title
      t.text    :description
      t.boolean :published

      t.timestamps
    end
  end
end
