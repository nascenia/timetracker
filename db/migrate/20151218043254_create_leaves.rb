class CreateLeaves < ActiveRecord::Migration
  def change
    create_table :leaves do |t|
      t.integer :user_id
      t.text :reason
      t.integer :leave_type
      t.integer :status

      t.timestamps
    end
  end
end
