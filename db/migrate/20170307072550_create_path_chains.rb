class CreatePathChains < ActiveRecord::Migration[7.0]
  def change
    create_table :path_chains do |t|
      t.references :approval_path, index: true
      t.integer :user_id, null: false
      t.integer :priority, null: false, default: 0

      t.timestamps
    end
  end
end
