class CreateLeaveComments < ActiveRecord::Migration[7.0]
  def change
    create_table :leave_comments do |t|
      t.string :comment
      t.references :leave, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
