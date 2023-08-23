class AddRegistrationStatusToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users , :registration_status , :integer , default: 0
  end
end
