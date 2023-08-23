class CreateApprovalPaths < ActiveRecord::Migration[7.0]
  def change
    create_table :approval_paths do |t|
      t.references :user, index: true
      t.boolean :active, null: false, default: false

      t.timestamps
    end
  end
end
