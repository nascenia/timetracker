class CreatePreRegistrations < ActiveRecord::Migration[7.0]
  def change
    create_table :pre_registrations do |t|
      t.string :name
      t.string :joiningDate
      t.string :datetime
      t.boolean :NdaSigned
      t.integer :user_id
      t.string :emailGroup
      t.string :contactNumber
      t.string :personalEmail
      t.string :companyEmail
      t.string :holiday_scheme_id
      t.string :weekend_id
      t.boolean :workstationReady
      t.boolean :packReady
      t.integer :step_no

      t.timestamps
    end
  end
end
